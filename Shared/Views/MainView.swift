//
//  MainView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import SwiftUI

struct MainView: View {
    private enum TabItem: String, Equatable, CaseIterable {
        case award
        case transfer
        case receive
//        case dao
        case settings
        
        var localizedName: LocalizedStringKey {
            if case .dao = self {
                return LocalizedStringKey(rawValue.uppercased())
            }
            return LocalizedStringKey(rawValue.capitalized)
        }
    }
    
    @State private var selectedItem: TabItem = TabItem.allCases.first!
    
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        TabView(selection: $selectedItem, content: {
            ForEach(TabItem.allCases, id: \.rawValue) { value in
                switch value {
                case .award:
                    NavigationView {
                        AwardView()
                            .navigationTitle(value.localizedName)
                            .navigationBarHidden(false)
                    }
                    .tabItem {
                        if selectedItem == value {
                            Image(systemName: "hand.thumbsup.fill")
                        } else {
                            Image(systemName: "hand.thumbsup")
                        }
                        Text(value.localizedName)
                    }
                    .tag(value)
                    .navigationViewStyle(StackNavigationViewStyle())
                case .transfer:
                    NavigationView {
                        TransferView()
                            .navigationTitle(value.localizedName)
                            .navigationBarHidden(false)
                    }
                    .tabItem {
                        if selectedItem == value {
                            Image(systemName: "arrow.up.heart.fill")
                        } else {
                            Image(systemName: "arrow.up.heart")
                        }
                        Text(value.localizedName)
                    }
                    .tag(value)
                    .navigationViewStyle(StackNavigationViewStyle())
                case .receive:
                    NavigationView {
                        ReceiveView()
                            .navigationTitle(value.localizedName)
                            .navigationBarHidden(false)
                    }
                    .tabItem {
                        if selectedItem == value {
                            Image(systemName: "arrow.down.heart.fill")
                        } else {
                            Image(systemName: "arrow.down.heart")
                        }
                        Text(value.localizedName)
                    }
                    .tag(value)
                    .navigationViewStyle(StackNavigationViewStyle())
                case .settings:
                    NavigationView {
                        SettingsView()
                            .navigationTitle(value.localizedName)
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Image(systemName: "gear")
                        Text(value.localizedName)
                    }
                    .tag(value)
                    .navigationViewStyle(StackNavigationViewStyle())
//                case .dao:
//                    NavigationView {
//                        DAOView()
//                            .navigationTitle(value.localizedName)
//                            .navigationBarHidden(false)
//                    }
//                    .tabItem {
//                        if selectedItem == value {
//                            Image(systemName: "building.columns.fill")
//                        } else {
//                            Image(systemName: "building.columns")
//                        }
//                        Text(value.localizedName)
//                    }
//                    .tag(value)
//                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
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
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.themeTextField)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
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
