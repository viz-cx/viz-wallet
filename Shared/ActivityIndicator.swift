//
//  ActivityIndicator.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 04.03.2021.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding private var isAnimating: Bool
    private let style: UIActivityIndicatorView.Style
    private let color: UIColor
    
    init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style, color: UIColor) {
        self._isAnimating = isAnimating
        self.style = style
        self.color = color
    }
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(style: style)
        indicatorView.color = color
        return indicatorView
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: .constant(true), style: .large, color: .gray)
    }
}
