//
//  DAOView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 06.03.2021.
//

import SwiftUI

struct DAOView: View {
    
    private enum Section: Int, CaseIterable {
        case witnesses = 0
        case committee
        
        var title: String {
            switch self {
            case .witnesses:
                return String(localized: "Witnesses")
            case .committee:
                return String(localized: "Committee")
            }
        }
    }
    
    @State private var selectedSection: Section = .witnesses

    var body: some View {
        VStack {
            Picker("Sections", selection: $selectedSection) {
                ForEach(Section.allCases, id: \.self) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)

            Spacer()

            switch selectedSection {
            case .witnesses:
                WitnessesView()
            case .committee:
                CommitteeView()
            }

            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
}

#Preview {
    DAOView()
}
