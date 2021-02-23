//
//  MainView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import SwiftUI

struct MainView: View {
    enum TabItem {
        case award
        case settings
    }
    
    @State var selectedItem: TabItem = .award
    
    var body: some View {
        TabView(selection: $selectedItem, content: {
            AwardView()
                .tabItem {
                    if selectedItem == .award {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                    Text("Award")
                }.tag(TabItem.award)
                
            Text("Settings View")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }.tag(TabItem.settings)
        })
        .font(.headline)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
