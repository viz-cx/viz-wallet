//
//  SettingsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 27.02.2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @State private var activePage = ""
    
    var body: some View {
        let isSubPageActive = Binding<Bool>(get: { self.activePage.count > 0 }, set: { _ in })
        VStack {
            Image("profile")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .center)
                .clipShape(Circle())
                .padding()
            VStack {
                Text(userAuth.login)
                    .font(.title)
                    .foregroundColor(.primary)
                Text("Profile description or registration date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            List {
                Label("Telegram support chat", systemImage: "bubble.left.and.bubble.right.fill")
                    .onTapGesture {
                        guard let url = URL(string: "https://t.me/viz_cx") else { return }
                        UIApplication.shared.open(url)
                    }
                Label("Privacy policy", systemImage: "lock.doc")
                    .onTapGesture {
                        activePage = "PrivacyPolicy"
                    }
                Label("Logout", systemImage: "person.fill")
                    .onTapGesture {
                        userAuth.logout()
                    }
            }
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
