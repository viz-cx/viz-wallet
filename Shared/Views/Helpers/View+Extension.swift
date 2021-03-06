//
//  View+Extension.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 05.03.2021.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
