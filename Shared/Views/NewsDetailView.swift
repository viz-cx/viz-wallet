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
    
    private var imageUrl: String = ""
    private var title: String = ""
    private var content = NSAttributedString()
    
    init(imageUrl: String, title: String, content: NSAttributedString) {
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
                
                LabelView(attributedString: content)
                    .padding([.leading, .trailing], 20)
            }
        }
    }
}

struct NewsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let html = "<h2>Начало работы</h2><p>Все остальные приглашённые тестировщики могут иметь доступ только к тем сборкам, которые им предоставит разработчик. Разработчик может пригласить вас принять участие в тестировании, отправив приглашение по электронной почте или в виде общедоступной ссылки.</p>"
        let data = Data(html.utf8)
        let attributedString = try! NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil)
        return NewsDetailView(
            imageUrl: "https://viz.media/wp-content/uploads/2021/03/testirovanie-beta-versii-prilozheniya-viz-social-capital.jpg",
            title: "Тестирование бета-версии приложения «VIZ Social Capital»",
            content: attributedString
        )
    }
}
