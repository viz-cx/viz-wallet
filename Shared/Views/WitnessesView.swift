//
//  WitnessesView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/10/26.
//

import SwiftUI
import VIZ

struct WitnessesView: View {
    
    @StateObject private var vm = WitnessesViewModel()
    
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
                WitnessRow(witness: witness)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(witness.owner)
                    .font(.headline)
                
                Spacer()
                
                Text("#\(witness.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("Votes: \(witness.votes?.value ?? API.Share(0).value)")
                .font(.subheadline)
            
//            HStack {
//                Text("Version \(witness.runningVersion ?? "")")
//                Spacer()
//                Text(witness.hardforkVersionVote ?? "")
//            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    WitnessesView()
}
