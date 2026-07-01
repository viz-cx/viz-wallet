//
//  WitnessesViewModel.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/10/26.
//

import Combine
import os

private let log = Logger(subsystem: "cx.viz.viz-wallet", category: "witnesses")

@MainActor
final class WitnessesViewModel: ObservableObject {

    private let viz = VIZHelper.shared

    @Published private(set) var witnesses: [VIZHelper.Witness] = []
    @Published private(set) var isLoading = false

    func updateWitnesses() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            self.witnesses = try await viz.getWitnessesByVote()
        } catch {
            self.witnesses = []
            log.error("Failed to load witnesses: \(error, privacy: .public)")
        }
    }

    func vote(for witness: VIZHelper.Witness, approve: Bool) async {
        // TODO: implement vote call
        log.debug("Vote \(approve ? "for" : "against", privacy: .public) \(witness.owner, privacy: .public)")
    }
}
