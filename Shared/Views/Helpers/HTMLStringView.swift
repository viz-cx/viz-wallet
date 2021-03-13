//
//  HTMLStringView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 13.03.2021.
//

import WebKit
import SwiftUI

struct LabelView: View {
    
    var attributedString: NSAttributedString

    @State private var height: CGFloat = .zero

    var body: some View {
        InternalLabelView(text: attributedString, dynamicHeight: $height)
            .frame(minHeight: height)
    }

    struct InternalLabelView: UIViewRepresentable {
        var text: NSAttributedString
        @Binding var dynamicHeight: CGFloat

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.attributedText = text

            DispatchQueue.main.async {
                dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            }
        }
    }
}
