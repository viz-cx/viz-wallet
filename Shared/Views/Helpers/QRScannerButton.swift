//
//  QRScannerButton.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI
import CodeScanner

struct QRScannerButton: View {
    @Binding var isShowingScanner: Bool
    let onScan: (String) -> Void
    
    var body: some View {
        Image(systemName: "qrcode.viewfinder")
            .font(.largeTitle)
            .colorInvert()
            .buttonStyle(.plain)
            .onTapGesture {
                isShowingScanner = true
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    scanMode: .oncePerCode,
                    simulatedData: "viz://@id"
                ) { result in
                    handle(result)
                }
            }
    }
    
    private func handle(_ result: Result<String, CodeScannerView.ScanError>) {
        guard case .success(let str) = result,
              str.hasPrefix("viz://"),
              let at = str.firstIndex(of: "@")
        else { return }
        onScan(String(str[str.index(after: at)...]))
        isShowingScanner = false
    }
}
