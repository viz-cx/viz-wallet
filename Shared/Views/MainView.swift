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
            NavigationView {
                AwardView()
                    .navigationTitle("Award")
                    .navigationBarHidden(false)
            }
            .tabItem {
                if selectedItem == .award {
                    Image(systemName: "hand.thumbsup.fill")
                } else {
                    Image(systemName: "hand.thumbsup")
                }
                Text("Award".localized())
            }
            .tag(TabItem.award)
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                TransferView()
                    .navigationTitle("Transfer")
                    .navigationBarHidden(false)
            }
            .tabItem {
                if selectedItem == .transfer {
                    Image(systemName: "arrow.up.heart.fill")
                } else {
                    Image(systemName: "arrow.up.heart")
                }
                Text("Transfer".localized())
            }
            .tag(TabItem.transfer)
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                ReceiveView()
                    .navigationTitle("Receive")
                    .navigationBarHidden(false)
            }
            .tabItem {
                if selectedItem == .receive {
                    Image(systemName: "arrow.down.heart.fill")
                } else {
                    Image(systemName: "arrow.down.heart")
                }
                Text("Receive".localized())
            }
            .tag(TabItem.receive)
            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                NewsView()
                    .environmentObject(newsState)
                    .navigationBarTitle("News")
                    .navigationBarHidden(false)
            }
            .tabItem {
                if selectedItem == .news {
                    Image(systemName: "newspaper.fill")
                } else {
                    Image(systemName: "newspaper")
                }
                Text("News".localized())
            }
            .tag(TabItem.news)
            .navigationViewStyle(StackNavigationViewStyle())
            
//            NavigationView {
//                DAOView()
//                    .navigationTitle("DAO")
//                    .navigationBarHidden(false)
//            }
//            .tabItem {
//                if selectedItem == .dao {
//                    Image(systemName: "building.columns.fill")
//                } else {
//                    Image(systemName: "building.columns")
//                }
//                Text("DAO".localized())
//            }
//            .tag(TabItem.dao)
//            .navigationViewStyle(StackNavigationViewStyle())
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings".localized())
            }
            .tag(TabItem.settings)
            .navigationViewStyle(StackNavigationViewStyle())
        })
        .font(.headline)
        .edgesIgnoringSafeArea(.top)
    }
    
    init() {
        let coloredNavAppearance = UINavigationBarAppearance()
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = .clear
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        coloredNavAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        
        UITabBar.appearance().barTintColor = UIColor(Color.themeTextField)
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.themeTextField)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
