//
//  AwardViewModel.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import Foundation
import VIZ

@MainActor
final class AwardViewModel: ObservableObject, Identifiable {
    private let viz: VIZHelper
    private let energyDivider = 5.0
    
    @Published var receiver = ""
    @Published var memo = ""
    @Published var percent = 0.0
    
    @Published var isLoading = false
    @Published var confettiCounter = 0
    @Published var showError = false
    @Published var errorText = ""
    
    let userAuth: UserAuthStore
    
    var currentEnergyPercent: Double {
        Double(userAuth.energy) / 100
    }
    
    var rewardEstimate: Double {
        calculateReward(
            energy: Int(percent * 100),
            effectiveVestingShares: userAuth.effectiveVestingShares,
            dgp: userAuth.dgp
        )
    }
    
    init(viz: VIZHelper = .shared, userAuth: UserAuthStore) {
        self.viz = viz
        self.userAuth = userAuth
        updateInitialPercent()
    }
    
    func updateInitialPercent() {
        let energy = currentEnergyPercent
        
        guard percent == 0, energy > 0 else {
            percent = min(percent, energy)
            return
        }
        
        percent = energy > 1
        ? round(energy / energyDivider)
        : round(energy / energyDivider * 10) / 10
    }
    
    func calculateReward(
        energy: Int,
        effectiveVestingShares: Double,
        dgp: VIZ.API.DynamicGlobalProperties?
    ) -> Double {
        guard let dgp else { return 0 }
        
        let voteShares = effectiveVestingShares * 100 * Double(energy)
        let totalRewardShares =
        (dgp.totalRewardShares as NSString).doubleValue + voteShares
        let totalRewardFund = dgp.totalRewardFund.resolvedAmount * 1000
        
        return ceil(totalRewardFund * voteShares / totalRewardShares) / 1000
    }
    
    func award() async {
        guard receiver.count > 1 else {
            errorText = "Please enter receiver name".localized()
            showError = true
            return
        }
        guard percent > 0 else {
            errorText = "Percent can't be less or equal to zero".localized()
            showError = true
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await userAuth.makeAward(receiver: receiver, energy: UInt16(percent * 100), memo: memo)
            onAwardSuccess()
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
    
    private func onAwardSuccess() {
        receiver = ""
        memo = ""
        percent = min(percent, currentEnergyPercent)
        
        confettiCounter += 1
        
        Task {
            await userAuth.updateUserData()
            await userAuth.updateDGPData()
            updateInitialPercent()
        }
    }
}

