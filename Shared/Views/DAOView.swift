//
//  DAOView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 06.03.2021.
//

import SwiftUI

struct DAOView: View {
    
    private enum Section: Int, CaseIterable {
        case committee = 0
        case delegates
        
        var title: String {
            switch self {
            case .committee:
                return "Committee"
            case .delegates:
                return "Delegates"
            }
        }
    }
    
    @State private var selectedIndex = Section.committee.rawValue
    @State private var sections = Section.allCases
    
    var body: some View {
        VStack {
            Picker("Sections", selection: $selectedIndex) {
                ForEach(0 ..< sections.count) { index in
                    Text(sections[index].title).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            switch sections[selectedIndex] {
            case .committee:
                Text("Committee view")
            case .delegates:
                Text("Delegates view")
            }
            
            Spacer()
        }
    }
}

struct DAOView_Previews: PreviewProvider {
    static var previews: some View {
        DAOView()
    }
}
