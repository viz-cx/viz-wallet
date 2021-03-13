//
//  Locales.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 13.03.2021.
//

import Foundation

public enum Locales {
    case english
    case russian
    case spanish
    
    public static var current: Locales {
        let locale: String = Locale.preferredLanguages.count > 0
            ? Locale.preferredLanguages[0]
            : NSLocale.current.languageCode ?? "en"
        if locale.starts(with: "ru") {
            return .russian
        }
        if locale.starts(with: "es") {
            return .spanish
        }
        return .english
    }
}
