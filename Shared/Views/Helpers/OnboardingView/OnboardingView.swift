//
//  OnboardingView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 20.03.2021.
//
// https://blckbirds.com/post/how-to-create-a-onboarding-screen-in-swiftui-2/

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userAuth: UserAuth
    
    private struct Page: Hashable {
        let title: String
        let description: String
        let imageName: String
    }
    
    private var subviews: [UIHostingController<LottieView>] = []
    
    private var titles: [String] = []
    
    private var captions: [String] = []
    
    @State var currentPageIndex = 0
    
    init() {
        let pages = [
            Page(title: "Делать что-то для других за деньги — это работа", description: "Вы обмениваете свои время, знания и силы на заранее известную сумму денег", imageName: "1"),
            Page(title: "Делать что-то интересное для себя — это отдых и развитие", description: "Вы тратите заработанные деньги на восстановление сил и новые впечатления", imageName: "2"),
            Page(title: "Делать что-то для других, не ожидая награды — что это?", description: "Не работа и не отдых, а новое, интересное и быстро растущее явление в нашей жизни", imageName: "3"),
            Page(title: "Когда вы делаете что-то для других не за деньги, люди вам благодарны", description: "Лайки, спасибо, аплодисменты, плюсы и большие пальцы вверх — это проявления благодарности", imageName: "4"),
            Page(title: "Сумма благодарностей от многих людей — ваш социальный капитал", description: "Чем больше людей вам благодарны, тем больше ваш социальный капитал", imageName: "5"),
        ]
        titles = pages.map { $0.title }
        captions = pages.map { $0.description }
        subviews = pages.map { UIHostingController(rootView: LottieView(name: $0.imageName)) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Close") {
                        userAuth.showOnboarding(show: false)
                    }
                }
                OnboardPageViewController(currentPageIndex: $currentPageIndex, viewControllers: subviews)
                    .frame(height: geometry.size.height / 2)
                
                VStack(spacing: 0) {
                    Group {
                        Text(titles[currentPageIndex])
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(captions[currentPageIndex])
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        OnboardPageControl(numberOfPages: subviews.count, currentPageIndex: $currentPageIndex)
                        Spacer()
                        Button(action: {
                            if self.currentPageIndex+1 == self.subviews.count {
                                self.currentPageIndex = 0
                            } else {
                                self.currentPageIndex += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(30)
                        }
                    }
                    .padding()
                }
                .frame(height: geometry.size.height / 2)
                
            }
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif
