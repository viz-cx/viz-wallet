//
//  OnboardingView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 20.03.2021.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userAuth: UserAuthStore
    
    private struct Page: Hashable {
        let title: String
        let description: String
        let imageName: String
    }
    
    private var subviews: [UIHostingController<LottieViewWithGradient>] = []
    private var titles: [String] = []
    private var captions: [String] = []
    
    @State var currentPageIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    init() {
        let pages = [
            Page(title: "Делать что-то для других за деньги — это работа",
                 description: "Вы обмениваете свои время, знания и силы на заранее известную сумму денег",
                 imageName: "1"),
            Page(title: "Делать что-то интересное для себя — это отдых и развитие",
                 description: "Вы тратите заработанные деньги на восстановление сил и новые впечатления",
                 imageName: "2"),
            Page(title: "Делать что-то для других, не ожидая награды — что это?",
                 description: "Не работа и не отдых, а новое, интересное и быстро растущее явление в нашей жизни",
                 imageName: "3"),
            Page(title: "Когда вы делаете что-то для других не за деньги, люди вам благодарны",
                 description: "Лайки, спасибо, аплодисменты, плюсы и большие пальцы вверх — это проявления благодарности",
                 imageName: "4"),
            Page(title: "Сумма благодарностей от многих людей — ваш социальный капитал",
                 description: "Чем больше людей вам благодарны, тем больше ваш социальный капитал",
                 imageName: "5"),
        ]
        titles = pages.map { $0.title }
        captions = pages.map { $0.description }
        subviews = pages.map {
            UIHostingController(rootView: LottieViewWithGradient(name: $0.imageName))
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.2),
                    Color.orange.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPageIndex)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Close button - modern floating style
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                userAuth.showOnboarding(show: false)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary.opacity(0.6))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                    }
                    
                    // Animation view with background
                    ZStack {
                        // Animated background circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.orange.opacity(0.15),
                                        Color.orange.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 320, height: 320)
                            .scaleEffect(1.0 + Double(currentPageIndex) * 0.05)
                            .animation(.easeInOut(duration: 0.5), value: currentPageIndex)
                        
                        OnboardPageViewController(currentPageIndex: $currentPageIndex, viewControllers: subviews)
                    }
                    .frame(height: geometry.size.height * 0.45)
                    .padding(.top, 20)
                    
                    // Content section
                    VStack(spacing: 24) {
                        // Text content with fade animation
                        VStack(spacing: 12) {
                            Text(titles[currentPageIndex])
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 32)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                                .id("title\(currentPageIndex)")
                            
                            Text(captions[currentPageIndex])
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 40)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                                .id("caption\(currentPageIndex)")
                        }
                        .animation(.easeInOut(duration: 0.3), value: currentPageIndex)
                        
                        Spacer()
                        
                        // Bottom controls
                        VStack(spacing: 20) {
                            // Custom page indicator
                            HStack(spacing: 8) {
                                ForEach(0..<subviews.count, id: \.self) { index in
                                    Capsule()
                                        .fill(currentPageIndex == index ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(width: currentPageIndex == index ? 24 : 8, height: 8)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPageIndex)
                                }
                            }
                            
                            // Navigation buttons
                            HStack(spacing: 16) {
                                // Skip button
                                if currentPageIndex < subviews.count - 1 {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            userAuth.showOnboarding(show: false)
                                        }
                                    }) {
                                        Text("Пропустить")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.gray.opacity(0.1))
                                            )
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                                
                                // Next/Finish button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if currentPageIndex + 1 == subviews.count {
                                            userAuth.showOnboarding(show: false)
                                        } else {
                                            currentPageIndex += 1
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Text(currentPageIndex + 1 == subviews.count ? "Начать" : "Далее")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        if currentPageIndex + 1 != subviews.count {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .animation(.easeInOut(duration: 0.3), value: currentPageIndex)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserAuthStore())
}
