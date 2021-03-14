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
        case news
        case settings
    }
    
    @State private var selectedItem: TabItem = .award
    
    @EnvironmentObject private var userAuth: UserAuth
    @EnvironmentObject private var newsState: NewsState
    
    var body: some View {
        TabView(selection: $selectedItem, content: {
            AwardView()
                .tabItem {
                    if selectedItem == .award {
                        Image(systemName: "hand.thumbsup.fill")
                    } else {
                        Image(systemName: "hand.thumbsup")
                    }
                    Text("Award".localized())
                }
                .tag(TabItem.award)
            
            TransferView()
                .tabItem {
                    if selectedItem == .transfer {
                        Image(systemName: "arrow.up.heart.fill")
                    } else {
                        Image(systemName: "arrow.up.heart")
                    }
                    Text("Transfer".localized())
                }
                .tag(TabItem.transfer)
            
            ReceiveView()
                .tabItem {
                    if selectedItem == .receive {
                        Image(systemName: "arrow.down.heart.fill")
                    } else {
                        Image(systemName: "arrow.down.heart")
                    }
                    Text("Receive".localized())
                }
                .tag(TabItem.receive)
            
            NewsView()
                .environmentObject(newsState)
                .tabItem {
                    if selectedItem == .news {
                        Image(systemName: "newspaper.fill")
                    } else {
                        Image(systemName: "newspaper")
                    }
                    Text("News".localized())
                }
                .tag(TabItem.news)
            
//            DAOView()
//                .tabItem {
//                    if selectedItem == .dao {
//                        Image(systemName: "building.columns.fill")
//                    } else {
//                        Image(systemName: "building.columns")
//                    }
//                    Text("DAO".localized())
//                }
//                .tag(TabItem.dao)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings".localized())
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
