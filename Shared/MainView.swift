//
//  MainView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import SwiftUI

struct MainView: View {
    private enum TabItem {
        case award
        case transfer
        case settings
    }
    
    @State private var selectedItem: TabItem = .award
    
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        TabView(selection: $selectedItem, content: {
            AwardView().environmentObject(userAuth)
                .tabItem {
                    if selectedItem == .award {
                        Image(systemName: "hand.thumbsup.fill")
                    } else {
                        Image(systemName: "hand.thumbsup")
                    }
                    Text("Award")
                }
                .tag(TabItem.award)
            
            TransferView()
                .tabItem {
                    // TODO: create custom Ƶ symbol
                    // https://developer.apple.com/documentation/xcode/creating_custom_symbol_images_for_your_app
                    if selectedItem == .transfer {
                        Image(systemName: "bitcoinsign.circle.fill")
                    } else {
                        Image(systemName: "bitcoinsign.circle")
                    }
                    Text("Transfer")
                }
                .tag(TabItem.transfer)
            
            SettingsView().environmentObject(userAuth)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(TabItem.settings)
        })
        .font(.headline)
    }
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color.themeTextField)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
