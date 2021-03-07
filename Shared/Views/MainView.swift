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
        case receive
        case dao
        case settings
    }
    
    @State private var selectedItem: TabItem = .award
    
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        TabView(selection: $selectedItem, content: {
            AwardView()
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
                    if selectedItem == .transfer {
                        Image(systemName: "arrow.up.heart.fill")
                    } else {
                        Image(systemName: "arrow.up.heart")
                    }
                    Text("Transfer")
                }
                .tag(TabItem.transfer)
            
            ReceiveView()
                .tabItem {
                    if selectedItem == .receive {
                        Image(systemName: "arrow.down.heart.fill")
                    } else {
                        Image(systemName: "arrow.down.heart")
                    }
                    Text("Receive")
                }
                .tag(TabItem.receive)
            
            DAOView()
                .tabItem {
                    if selectedItem == .dao {
                        Image(systemName: "building.columns.fill")
                    } else {
                        Image(systemName: "building.columns")
                    }
                    Text("DAO")
                }
                .tag(TabItem.dao)
            
            SettingsView()
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
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
