//
//  LabelView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 13.03.2021.
//

import SwiftUI
import Atributika

struct LabelView: View {
    
    var text: String
    
    @State private var height: CGFloat = .zero
    
    var body: some View {
        InternalLabelView(text: text, dynamicHeight: $height)
            .frame(minHeight: height)
    }
    
    struct InternalLabelView: UIViewRepresentable {
        var text: String
        @Binding var dynamicHeight: CGFloat
        private let allStyle = Style.font(UIFont.preferredFont(from: .body))
        private let linkStyle = Style("a")
            .foregroundColor(.blue, .normal)
            .foregroundColor(.brown, .highlighted)
        
        func makeUIView(context: Context) -> AttributedLabel {
            let label = AttributedLabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.attributedText = text
                .style(tags: linkStyle)
                .styleLinks(linkStyle)
                .styleAll(allStyle)
            
            label.onClick = { label, detection in
                switch detection.type {
                case .tag(let tag):
                    if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                        UIApplication.shared.open(url)
                    }
                case .link(let url):
                    UIApplication.shared.open(url)
                case .mention(_):
//                    if let url = URL(string: "https://viz.cx/award/\(name)") {
//                        UIApplication.shared.openURL(url)
//                    }
                    break
                default:
                    break
                }
            }
            
            return label
        }
        
        func updateUIView(_ uiView: AttributedLabel, context: Context) {
            uiView.attributedText = text
                .style(tags: linkStyle)
                .styleLinks(linkStyle)
                .styleAll(allStyle)
            
            DispatchQueue.main.async {
                dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            }
        }
    }
}
