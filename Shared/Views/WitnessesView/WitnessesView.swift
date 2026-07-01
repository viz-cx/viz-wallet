//
//  WitnessesView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/10/26.
//

import SwiftUI
import VIZ

struct WitnessesView: View {
    
    @State private var vm = WitnessesViewModel()
    
    var body: some View {
        List {
            if vm.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            ForEach(vm.witnesses, id: \.id) { witness in
                WitnessRow(
                    witness: witness,
                    onVote: { approve in
                        Task {
                            await vm.vote(for: witness, approve: approve)
                        }
                    }
                )
            }
        }
        .refreshable(action: {
            await vm.updateWitnesses()
        })
        .listStyle(.plain)
        .navigationTitle("Witnesses")
        .task {
            await vm.updateWitnesses()
        }
    }
}

private struct WitnessRow: View {
    let witness: VIZHelper.Witness
    let onVote: (Bool) -> Void
    
    @State private var isExpanded = false
    @State private var isVoted = false
    @State private var showConfirm = false
    @State private var pendingVoteValue = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 6) {
                
                Toggle("Vote", isOn: Binding(
                    get: { isVoted },
                    set: { newValue in
                        pendingVoteValue = newValue
                        showConfirm = true
                    }
                ))
                .toggleStyle(.switch)
                .padding(.vertical, 4)
                
                parametersView
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        } label: {
            header
        }
        .confirmationDialog(
            "Confirm vote?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Confirm") {
                isVoted = pendingVoteValue
                onVote(pendingVoteValue)
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
}

private extension WitnessRow {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(witness.owner)
                    .font(.headline)
                
                Spacer()
                
                Text("#\(witness.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("Votes: \(witness.votes?.value.description ?? "0")")
                .font(.subheadline)
        }
        .padding(.vertical, 6)
    }
    
    var parametersView: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            if let version = witness.runningVersion {
                row("Node version", version)
            }
            
            if let penalty = witness.penaltyPercent {
                row("Penalty for skipping blocks", "\(penalty)%")
            }
            
            if let maxBlock = witness.props?.maximumBlockSize {
                row("Maximum block size (bytes)", "\(maxBlock)")
            }
            
            if let fee = witness.props?.accountCreationFee {
                row("Account creation fee", fee.description)
            }
            
            if let ratio = witness.props?.createAccountDelegationRatio {
                row("Delegation coefficient", "\(ratio)")
            }
            
            if let time = witness.props?.createAccountDelegationTime {
                row("Delegation period (seconds)", "\(time)")
            }
            
            if let minDelegation = witness.props?.minDelegation {
                row("Minimum delegation", minDelegation.description)
            }
            
            if let minVote = witness.props?.voteAccountingMinRshares {
                row("Minimum reward shares weight", "\(minVote)")
            }
            
            if let intervals = witness.props?.withdrawIntervals {
                row("Unstake periods (days)", "\(intervals)")
            }
            
            if let witnessPercent = witness.props?.inflationWitnessPercent {
                row("Emission to witnesses", "\(witnessPercent)%")
            }
            
            if let daoPercent = witness.props?.inflationRatioCommitteeVsRewardFund {
                row("DAO Fund emission share", "\(daoPercent)%")
            }
            
            if let period = witness.props?.inflationRecalcPeriod {
                row("Inflation recalculation blocks", "\(period)")
            }
            
            if let penaltyPercent = witness.props?.witnessMissPenaltyPercent {
                row("Missed block penalty", "\(penaltyPercent)%")
            }
            
            if let penaltyDuration = witness.props?.witnessMissPenaltyDuration {
                row("Penalty duration (seconds)", "\(penaltyDuration)")
            }
            
            if let fee = witness.props?.committeeCreateRequestFee {
                row("DAO request fee", fee.description)
            }
            
            if let fee = witness.props?.createPaidSubscriptionFee {
                row("Paid subscription fee", fee.description)
            }
            
            if let fee = witness.props?.accountOnSaleFee {
                row("Account sale fee", fee.description)
            }
            
            if let fee = witness.props?.subaccountOnSaleFee {
                row("Subaccount sale fee", fee.description)
            }
            
            if let fee = witness.props?.witnessDeclarationFee {
                row("Witness declaration fee", fee.description)
            }
        }
    }
    
    func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}


#Preview {
    WitnessesView()
}
