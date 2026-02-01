//
//  AwardView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import SwiftUI

struct AwardView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @StateObject var vm: AwardViewModel
    @State private var isShowingScanner = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                
                AwardHeaderView(userAuth: vm.userAuth)
                
                ReceiverView(
                    isShowingScanner: $isShowingScanner,
                    receiver: $vm.receiver
                )
                
                AwardMemoField(text: $vm.memo)
                
                AwardSlider(
                    percent: $vm.percent,
                    reward: vm.rewardEstimate
                )
                
                if vm.isLoading {
                    ActivityIndicator(isAnimating: $vm.isLoading)
                } else {
                    AwardButton {
                        Task { await vm.award() }
                    }
                }
            }
            .padding(.horizontal, 16)
            .confetti(trigger: $vm.confettiCounter)
            .alert("Error".localized(), isPresented: $vm.showError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(vm.errorText)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}


#Preview {
    let userAuth = UserAuth()
    AwardView(vm: AwardViewModel(userAuth: userAuth))
        .environmentObject(userAuth)
}
