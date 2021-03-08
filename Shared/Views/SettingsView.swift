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
        VStack {
            WebImage(url: URL(string: userAuth.accountAvatar))
                .resizable()
                .placeholder(Image("profile"))
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
            VStack {
                Text(userAuth.accountNickname)
                    .font(.title)
                    .foregroundColor(.primary)
                    .colorInvert()
                Text(userAuth.accountAbout)
                    .font(.subheadline)
                    .colorInvert()
            }
            
            List {
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
