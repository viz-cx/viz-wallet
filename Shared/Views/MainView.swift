//
//  MainView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import SwiftUI

struct MainView: View {
    private enum TabItem: String, Equatable, CaseIterable {
        case award
        case transfer
        case receive
        case dao
        case settings

        var localizedName: LocalizedStringKey {
            if case .dao = self {
                return LocalizedStringKey(rawValue.uppercased())
            }
            return LocalizedStringKey(rawValue.capitalized)
        }

        func systemImage(selected: Bool) -> String {
            switch self {
            case .award:    return selected ? "hand.thumbsup.fill" : "hand.thumbsup"
            case .transfer: return selected ? "arrow.up.heart.fill" : "arrow.up.heart"
            case .receive:  return selected ? "arrow.down.heart.fill" : "arrow.down.heart"
            case .dao:      return selected ? "building.columns.fill" : "building.columns"
            case .settings: return "gear"
            }
        }

        /// Settings hides its navigation bar; every other tab shows it.
        var navigationBarVisibility: Visibility {
            self == .settings ? .hidden : .visible
        }
    }

    @State private var selectedItem: TabItem = TabItem.allCases.first!
    @Environment(UserAuthStore.self) private var userAuth

    var body: some View {
        TabView(selection: $selectedItem) {
            ForEach(TabItem.allCases, id: \.rawValue) { item in
                NavigationStack {
                    destination(for: item)
                        .navigationTitle(item.localizedName)
                        .toolbar(item.navigationBarVisibility, for: .navigationBar)
                }
                .tabItem {
                    Image(systemName: item.systemImage(selected: selectedItem == item))
                    Text(item.localizedName)
                }
                .tag(item)
            }
        }
        .font(.headline)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private func destination(for item: TabItem) -> some View {
        switch item {
        case .award:    AwardView(vm: AwardViewModel(userAuth: userAuth))
        case .transfer: TransferView()
        case .receive:  ReceiveView()
        case .dao:      DAOView()
        case .settings: SettingsView()
        }
    }

    init() {
        Self.configureAppearance()
    }

    private static func configureAppearance() {
        let coloredNavAppearance = UINavigationBarAppearance()
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = .clear
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.themeTextField)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        UITabBar.appearance().barTintColor = UIColor(Color.themeTextField)

        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
}

#Preview {
    MainView()
}
