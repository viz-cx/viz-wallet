//
//  SettingsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 27.02.2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 32) {
                    profileHeader
                    settingsOptions
                }
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            profileAvatar
            profileInfo
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var profileAvatar: some View {
        if let avatar = userAuth.accountMetadata?.profile.avatar {
            AsyncImage(url: URL(string: avatar)) { image in
                image.resizable()
            } placeholder: {
                ActivityIndicator(isAnimating: .constant(true))
            }
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .white.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        } else { // placeholder
            Image("profile")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        }
    }
    
    private var profileInfo: some View {
        VStack(spacing: 8) {
            if let nickname = userAuth.accountMetadata?.profile.nickname {
                Text(nickname)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            if let about = userAuth.accountMetadata?.profile.about {
                Text(about)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    // MARK: - Settings Options
    
    private var settingsOptions: some View {
        VStack(spacing: 12) {
            SettingsRowView(
                title: "Telegram".localized(),
                systemImage: "paperplane.fill",
                iconColor: .blue
            ) {
                openTelegram()
            }
            
            SettingsRowView(title: "Onboarding".localized(), systemImage: "building.2.crop.circle.fill", iconColor: .blue) {
                userAuth.showOnboarding(show: true)
            }
            
            SettingsRowView(title: "Privacy policy".localized(), systemImage: "lock.doc", iconColor: .gray) {
                print("TODO: Show Privacy policy")
            }
            
            SettingsRowView(
                title: "Application settings".localized(),
                systemImage: "gearshape.fill",
                iconColor: .gray
            ) {
                openAppSettings()
            }
            
            SettingsRowView(
                title: "Logout".localized(),
                systemImage: "arrow.backward.circle.fill",
                iconColor: .red,
                isDestructive: true,
            ) {
                userAuth.logout()
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    
    private func openTelegram() {
        guard let url = URL(string: "https://t.me/viz_cx") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Settings Row Component

struct SettingsRowView: View {
    let title: String
    let systemImage: String
    let iconColor: Color
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                iconView
                
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(SettingsButtonStyle())
    }
    
    private var iconView: some View {
        Image(systemName: systemImage)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(isDestructive ? .red : iconColor)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(isDestructive ? .red.opacity(0.15) : iconColor.opacity(0.15))
            )
    }
}

// MARK: - Button Style

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserAuth())
}
