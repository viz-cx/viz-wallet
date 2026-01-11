//
//  WitnessesViewModel.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/10/26.
//

import Combine

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
            print(error)
        }
    }
}
