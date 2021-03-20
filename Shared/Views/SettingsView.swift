//
//  SettingsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 27.02.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @State private var activePage = ""
    
    var body: some View {
        let isSubPageActive = Binding<Bool>(get: { self.activePage.count > 0 }, set: { _ in })
        
        let header = VStack {
            HStack {
                Spacer()
                WebImage(url: URL(string: userAuth.accountAvatar))
                    .resizable()
                    .placeholder(Image("profile"))
                    .frame(width: 200, height: 200, alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(radius: 10)
                Spacer()
            }
            HStack {
                Spacer()
                VStack {
                    Text(userAuth.accountNickname)
                        .font(.title)
                        .foregroundColor(.primary)
                        .colorInvert()
                    Text(userAuth.accountAbout)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .colorInvert()
                }
                Spacer()
            }
        }
        
        VStack {
            List {
                Section(header: header) {
                    Label("Telegram".localized(), systemImage: "paperplane.circle.fill")
                        .onTapGesture {
                            guard let url = URL(string: "https://t.me/viz_cx") else { return }
                            UIApplication.shared.open(url)
                        }
                        .listRowBackground(Color.clear)
                        .foregroundColor(.white)
                    
//                Label("Privacy policy".localized(), systemImage: "lock.doc")
//                    .onTapGesture {
//                        activePage = "PrivacyPolicy"
//                    }
//                    .listRowBackground(Color.clear)
//                    .foregroundColor(.white)
                    
                    Label("Onboarding".localized(), systemImage: "building.2.crop.circle.fill")
                        .onTapGesture {
                            userAuth.showOnboarding(show: true)
                        }
                        .listRowBackground(Color.clear)
                        .foregroundColor(.white)
                    
                    Label("Change language".localized(), systemImage: "gearshape.fill")
                        .onTapGesture {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                        .listRowBackground(Color.clear)
                        .foregroundColor(.white)
                    
                    Label("Logout".localized(), systemImage: "person.fill")
                        .onTapGesture {
                            userAuth.logout()
                        }
                        .listRowBackground(Color.clear)
                        .foregroundColor(.white)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .fullScreenCover(isPresented: isSubPageActive, onDismiss: {
                activePage = ""
            }, content: {
                VStack {
                    switch activePage {
                    case "PrivacyPolicy":
                        Text("Privacy Policy")
                    default:
                        Text("Not supported now")
                    }
                    Spacer()
                    Button("Dismiss") {
                        self.activePage = ""
                    }
                }
            })
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(UserAuth())
    }
}
