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
    
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(uiImage: generateQRImage(text: "viz://award/@\(userAuth.login)"))
                .interpolation(.none)
                .resizable()
                .frame(maxWidth: .infinity, alignment: .center)
                .aspectRatio(1, contentMode: .fit)
                .padding([.bottom], 10)
            VStack{
            Text("\("Login".localized()): \(userAuth.login)")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(
                    maxWidth: .infinity,
                    minHeight: 50,
                    maxHeight: 50,
                    alignment: .center
                )
                .border(Color.white, width: 3.0)
                .cornerRadius(7.5)
                .onTapGesture {
                    UIPasteboard.general.string = userAuth.login
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            .padding([.leading, .trailing], 27.5)
            
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    func generateQRImage(text: String) -> UIImage {
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

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView().environmentObject(UserAuth())
    }
}
