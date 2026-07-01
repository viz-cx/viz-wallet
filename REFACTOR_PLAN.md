# viz-wallet — Modernization & Refactor Plan

> Status: **PLANNED — not started.** Written 2026-07-01.
> Scope chosen by owner: **Full modernization**, **raise iOS floor to 17**, executed in a **fresh session** (this doc is the handoff — implement with no re-derivation needed).

## Context snapshot (as of planning)

- SwiftUI VIZ-blockchain wallet. **46 Swift files, ~4,500 LOC.**
- Toolchain: **Swift 6.3.1 / Xcode 26**. Project builds today; the in-progress `WitnessesView/` folder move is already reflected in `project.pbxproj`.
- Recently-refactored areas are already clean MVVM + `async/await` + actor isolation: `Data/Auth/*`, `AwardView/*`, `TransferView/*`, `WitnessesView/*`, `SettingsView`. **Use these as the style reference.** Don't "modernize" them further except where a phase below names them.
- Config today:
  - `SWIFT_VERSION = 5.0` everywhere, but `SWIFT_STRICT_CONCURRENCY = complete` on the app configs.
  - iOS **app** target: `IPHONEOS_DEPLOYMENT_TARGET = 17.0`. iOS **test** targets: `14.4`. macOS app: `11.0`, macOS tests: `11.1`.
  - No `#if os()` guards anywhere, yet Shared code uses `UIApplication`, `UINavigationBarAppearance`, `UITabBar`, `UIPasteboard`, `.autocapitalization`. **The macOS target therefore almost certainly does not build the shared UI** — treat it as unverified/likely-dead (see Phase 0).

## Guiding rules

- **No behavior changes** except where a phase explicitly says so (e.g. dropping the dead registration flow).
- Match surrounding style: file header comment block, `// MARK:` sections, `private` view helpers in extensions (see `WitnessesView.swift`, `SettingsView.swift`).
- **Build after every phase.** `xcodebuild -project viz-wallet.xcodeproj -scheme "viz-wallet (iOS)" -destination 'generic/platform=iOS' build` (or an available simulator destination). Commit per phase.
- Do NOT commit `REFACTOR_PLAN.md` deletions until the end; keep it as the running checklist.

---

## Phase 0 — Decide the macOS target (do first; it gates everything)

The macOS app target compiles `Shared/` but that code is UIKit-only with no platform guards. Before any modernization:

1. Try to build the macOS scheme. If it fails (expected), confirm the target is unused/abandoned.
2. **Decision needed from owner** (ask if unclear): either
   - (a) **Drop the macOS app + `Tests macOS` targets** from `project.pbxproj` (recommended — simplifies everything, no `#if os()` noise), or
   - (b) Keep it and wrap all UIKit usage in `#if canImport(UIKit)` — much more work.
3. This plan assumes **(a)**. If (b), each later phase's UIKit edits must be `#if`-guarded.

---

## Phase 1 — Project config (fast, high value)

File: `viz-wallet.xcodeproj/project.pbxproj`

1. Set `SWIFT_VERSION = 6.0` on **all** remaining build configs (currently `5.0`).
2. Unify deployment targets:
   - `IPHONEOS_DEPLOYMENT_TARGET = 17.0` on the iOS **test** targets (`Tests iOS`, `viz-walletUITests`) — currently `14.4`.
   - macOS targets: resolve per Phase 0 (drop, or set both to a single value).
3. Keep `SWIFT_STRICT_CONCURRENCY = complete` (already set) and ensure it's on every target so Swift 6 mode is consistent.
4. Build. **Expect concurrency diagnostics to surface here** — fix them as they appear (the code is close, but Swift 6 mode is stricter than `complete` checking in 5 mode). Likely spots: `VIZHelper` static funcs, `AppDelegate`, `registerDefaultsFromSettingsBundle` global func.

Commit: `Bump to Swift 6 language mode, unify deployment targets to iOS 17`.

---

## Phase 2 — Remove dead & debug code (low risk, do before restructuring)

1. **`Shared/Views/Helpers/String+Extension.swift`** — `decodingHTMLEntities()` and its private helpers/entity table (~370 lines) have **zero call sites**. Delete everything except the `localized(_:)` extension at the top (lines ~10–15). (The `localized` wrapper itself is removed in Phase 6 — keep it for now so intermediate builds pass.)
2. **`Shared/Views/RegistrationView.swift`** — the registration flow is stubbed: `registration()` is empty, ~80 lines are commented out, and it reads `login`/`password` from `""` literals. Decision needed:
   - If registration is genuinely unsupported now → delete the commented blocks and either gut the view to a "coming soon"/removed entry point, and remove the "Sign Up with an invite code" tap target in `LoginView.swift`.
   - If it's meant to return → leave a single `// TODO:` and open a tracking note; don't leave 80 commented lines.
   - **Ask the owner** which. Default assumption: registration is dead → remove.
3. If registration is removed, **`VIZHelper.inviteRegistration(...)` and `accountUpdate(...)`** become dead (only referenced from the commented code). Remove them too, plus now-unused `VIZKeyType`/`privateKey(fromAccount:)` if nothing else uses them (verify with grep first).
4. Replace `print()` calls (×8) — remove pure debug ones; for error paths use `os.Logger`:
   - `WitnessesViewModel`: delete the `didSet { print(witnesses) }` entirely; replace the `catch { print(error) }` with a `Logger` call.
   - `WalletApp.handleURL`, `UserAuthActor`/`Store`, etc.: remove or convert to `Logger`.
   - Add one `Logger` per subsystem, e.g. `private let log = Logger(subsystem: "cx.viz.viz-wallet", category: "auth")`.

Commit: `Remove dead HTML-entity code, stubbed registration, and debug prints`.

---

## Phase 3 — Fix real bugs / smells (small, targeted)

File: `Shared/Data/Auth/UserAuthStore.swift`
1. `auth(login:key:)` assigns `self.balance = account.balance.resolvedAmount` **twice** (lines 77 & 81). Remove the duplicate.
2. Remove `MainActor.assertIsolated()` from `init()` (noise; the class is already `@MainActor`).
3. **Error-strategy consistency:** `auth()` returns `Result<Void, Error>` while every other method `throws`. Convert `auth()` to `async throws` and update its two call sites (`LoginView.signIn()` and `restore()`), OR document why `Result` is intentional. Prefer converting to `throws` for consistency.

Commit: `Fix double balance assignment and unify auth error handling`.

---

## Phase 4 — `MainView` dedup + NavigationStack

File: `Shared/Views/MainView.swift`
1. Collapse the 5 near-identical `NavigationView` tab cases into a data-driven list. Extend the `TabItem` enum with computed `systemImage(selected:)` and a `@ViewBuilder destination` (or a small factory), then one `ForEach`/`Tab` block. Target ~30 lines vs current ~110.
2. Replace `NavigationView` + `.navigationViewStyle(StackNavigationViewStyle())` → **`NavigationStack`**.
3. Replace `.edgesIgnoringSafeArea(.top)` → `.ignoresSafeArea(edges: .top)`.
4. The `init()` UIKit appearance block (`UINavigationBarAppearance`, `UITabBar.appearance()`, `UITableView.appearance()`) — keep for now (global appearance still needs UIKit), but move it into a small helper (`configureAppearance()`) or an `.onAppear` guarded once. Keep behavior identical.
5. iOS 17: consider the new `TabView` `Tab` API, but `ForEach`+`.tag` is fine — don't over-reach.

Commit: `Refactor MainView to data-driven NavigationStack tabs`.

---

## Phase 5 — Sweep remaining deprecated SwiftUI APIs

Across `LoginView`, `RegistrationView`, `ReceiveView`, `DAOView`, and any others (grep to confirm counts):
1. `NavigationView` → `NavigationStack` (all remaining ×11 total incl. MainView).
2. `.navigationBarHidden(true)` → `.toolbar(.hidden, for: .navigationBar)` (or `.navigationBarBackButtonHidden` where that's the intent). ×7.
3. `.autocapitalization(.none)` → `.textInputAutocapitalization(.never)`. ×12.
4. `.edgesIgnoringSafeArea(...)` → `.ignoresSafeArea(...)`. ×5 (some already done in newer views).
5. `SegmentedPickerStyle()`/`StackNavigationViewStyle()` → `.segmented` / removed.
6. `DAOView`: `ForEach(0 ..< sections.count, id: \.self)` → iterate the enum's `allCases` directly with `Picker(selection:)`.

Verify each screen still lays out (build + quick visual check via the `run`/`verify` skills if a simulator is available).

Commit: `Replace deprecated SwiftUI APIs with iOS 17 equivalents`.

---

## Phase 6 — Observation migration + localization cleanup

1. **Migrate 4 view models to `@Observable`** (iOS 17):
   - `UserAuthStore`, `AwardViewModel`, `TransferViewModel`, `WitnessesViewModel`.
   - `@Observable final class X` (keep `@MainActor`); drop `ObservableObject`/`@Published`. Keep `private(set)` on read-only state.
   - Call sites: `@StateObject` → `@State`, `@EnvironmentObject` → `@Environment(UserAuthStore.self)`, `.environmentObject(store)` → `.environment(store)`. Update `WalletApp`, `MainView`, `LoginView`, `ReceiveView`, `SettingsView`, `AwardView`, `TransferView`, and every `#Preview`.
   - `WitnessesViewModel`/`AwardViewModel`/`TransferViewModel` bindings that used `$vm.x` now need `@Bindable var vm` (or `$vm` via `@Bindable`) in the consuming views — update `AwardView`, `TransferView`, `TransferFormView`, `AwardSlider`, `ReceiverView`, `AwardMemoField` accordingly.
   - `import Combine` becomes unnecessary in the VMs — remove.
2. **Localization:** the app has migrated to `Localizable.xcstrings`, but 35 `.localized()` calls and the custom `String.localized(_:)` wrapper remain, applied inconsistently. SwiftUI `Text`/view initializers auto-localize `LocalizedStringKey`. Plan:
   - For `Text(...)`, `TextField(placeholder,...)`, `.navigationTitle`, `Button(title)` etc., **drop `.localized()`** and pass the literal — SwiftUI localizes it against the catalog.
   - For non-View strings that genuinely need manual lookup (e.g. `errorText` assignments, `UIPasteboard`), replace `.localized()` with `String(localized:)`.
   - Delete the `String.localized(_:)` extension once call sites are gone. Verify every removed key still exists in `Localizable.xcstrings`.
   - This is the churniest phase — do it screen-by-screen, building between each.

Commit(s): one per concern — `Migrate view models to @Observable`, then `Adopt native SwiftUI/String(localized:) localization`.

---

## Phase 7 — Final verification

1. Full build of the iOS scheme, Release + Debug configs, zero warnings ideally (at least no new ones).
2. Run `viz_walletUITests` / `Tests iOS` — confirm the UI-testing hook (`-ui-testing` arg in `AppDelegate`) and accessibility identifiers (`login`, `regular`, `signin`) referenced by tests still exist after Phase 5/6 edits.
3. Launch in simulator; smoke-test: login (demo creds path), award, transfer, receive QR, settings, DAO/witnesses list.
4. Delete `REFACTOR_PLAN.md`.

Commit: `Modernization complete`.

---

## Quick reference — file inventory touched

| Phase | Files |
|---|---|
| 0–1 | `project.pbxproj` |
| 2 | `String+Extension.swift`, `RegistrationView.swift`, `VIZHelper.swift`, `WitnessesViewModel.swift`, `WalletApp.swift`, `UserAuthActor.swift` |
| 3 | `UserAuthStore.swift`, `LoginView.swift` |
| 4 | `MainView.swift` |
| 5 | `LoginView.swift`, `RegistrationView.swift`, `ReceiveView.swift`, `DAOView.swift` |
| 6 | all 4 view models + every view that consumes them + all `#Preview`s |

## Open questions for the owner (resolve at start of impl session)
1. **macOS target**: drop it, or keep + guard? (Plan assumes drop.)
2. **Registration flow**: dead (remove) or coming back (keep a TODO)? (Plan assumes dead.)
