//
//  LottieViewWithGradient.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 12/26/25.
//

import SwiftUI
import Lottie

struct LottieViewWithGradient: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func makeUIView(context: Context) -> UIView {
        let containerView = ContainerView()
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemOrange.withAlphaComponent(0.2).cgColor,
            UIColor.systemOrange.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.gradientLayer = gradientLayer
        
        // Create animation view
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .clear
        
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        animationView.play()
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Gradient frame is now handled by ContainerView's layoutSubviews
    }
    
    // Custom container view that updates gradient on layout
    class ContainerView: UIView {
        var gradientLayer: CAGradientLayer?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer?.frame = bounds
            CATransaction.commit()
        }
    }
}
