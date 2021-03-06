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
            Text("Login: \(userAuth.login)")
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
                .cornerRadius(15.0)
                .onTapGesture {
                    UIPasteboard.general.string = userAuth.login
                }
            
            Spacer()
            
            Image(uiImage: genrateQRImage(text: userAuth.login))
                .interpolation(.none)
                .resizable()
                .frame(maxHeight: 300, alignment: .center)
                .aspectRatio(1, contentMode: .fit)
            
            Spacer()
        }
    }
    
    func genrateQRImage(text: String) -> UIImage {
        let data = Data(text.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCodeImage = filter.outputImage {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView()
    }
}
