//
//  String+Extension.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 08.03.2021.
//

import Foundation

extension String {
    func localized(_ withComment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}
