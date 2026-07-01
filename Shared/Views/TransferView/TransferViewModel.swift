//
//  TransferViewModel.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/29/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class TransferViewModel {
    var receiver = ""
    var amount: Double?
    var memo = ""
    var isShowingScanner = false
    var isLoading = false
    var showError = false
    var errorText = ""
    var confetti = 0
    
    func clampAmount(to balance: Double) {
        guard let amount, amount > balance else { return }
        self.amount = balance
    }
    
    func transfer(
        viz: VIZHelper,
        auth: UserAuthStore
    ) async {
        guard let amount else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await auth.makeTransfer(receiver: receiver, amount: amount, memo: memo)
            
            receiver = ""
            self.amount = nil
            memo = ""
            confetti += 1
            
            await auth.updateUserData()
            await auth.updateDGPData()
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
}
