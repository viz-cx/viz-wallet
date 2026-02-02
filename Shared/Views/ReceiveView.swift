//
//  ReceiveView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 28.02.2021.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct ReceiveView: View {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    @EnvironmentObject private var userAuth: UserAuthStore
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                    
                    Image(uiImage: generateQRImage(text: "viz://award/@\(userAuth.login)"))
                        .interpolation(.none)
                        .resizable()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1, contentMode: .fit)
                        .padding([.top, .leading, .trailing, .bottom], geometry.size.width * 0.2)
                        .onTapGesture {
                            copyToClipboard()
                        }
                    
                    VStack {
                        Text("\("Login".localized()): \(userAuth.login)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 50,
                                maxHeight: 50,
                                alignment: .center
                            )
                            .cornerRadius(7.5)
                            .onTapGesture {
                                copyToClipboard()
                            }
                    }
                    .padding([.leading, .trailing], 16.0)
                    
                    Spacer()
                }
                
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = userAuth.login
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func generateQRImage(text: String) -> UIImage {
        let data = Data(text.utf8)
        filter.setValue(data, forKey: "inputMessage")
        let colorParameters = [
            "inputColor0": CIColor(color: UIColor.white),
            "inputColor1": CIColor(color: UIColor.clear)
        ]
        if let qrCodeImage = filter.outputImage {
            let colored = qrCodeImage.applyingFilter("CIFalseColor", parameters: colorParameters)
            if let qrCodeCGImage = context.createCGImage(colored, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}

#Preview {
    ReceiveView()
        .environmentObject(UserAuthStore())
}
