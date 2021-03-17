//
//  NewsDetailView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 13.03.2021.
//

import SwiftUI
import WordpressKit
import SDWebImageSwiftUI

struct NewsDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private var imageUrl: String
    private var title: String
    private var content: String
    
    init(imageUrl: String, title: String, content: String) {
        self.imageUrl = imageUrl
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack {
            ScrollView {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                
                Text(title)
                    .font(.title3)
                    .padding([.leading, .trailing], 5)
                
                LabelView(text: content)
                    .padding([.leading, .trailing], 20)
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Dismiss".localized())
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 50,
                            maxHeight: 50,
                            alignment: .center
                        )
                        .background(Color.green)
                        .opacity(0.95)
                        .cornerRadius(15.0)
                        .padding([.leading, .trailing, .bottom], 16.0)
                }
            }
        }
    }
}

struct NewsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return NewsDetailView(
            imageUrl: "https://viz.media/wp-content/uploads/2021/03/testirovanie-beta-versii-prilozheniya-viz-social-capital.jpg",
            title: "Тестирование бета-версии приложения «VIZ Social Capital»",
            content: "<h2>Начало работы</h2><p>Все остальные приглашённые тестировщики могут иметь доступ только к тем сборкам, которые им предоставит разработчик. Разработчик может пригласить вас принять участие в тестировании, отправив приглашение по электронной почте или в виде общедоступной ссылки.</p>"
        )
    }
}
