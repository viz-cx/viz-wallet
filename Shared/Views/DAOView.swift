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
                return "Witnesses".localized()
            case .committee:
                return "Committee".localized()
            }
        }
    }
    
    @State private var selectedIndex = Section.witnesses.rawValue
    @State private var sections = Section.allCases
    
    var body: some View {
        VStack {
            Picker("Sections", selection: $selectedIndex) {
                ForEach(0 ..< sections.count, id: \.self) { index in
                    Text(sections[index].title).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            switch sections[selectedIndex] {
            case .witnesses:
                WitnessesView()
            case .committee:
                CommitteeView()
            }
            
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
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
