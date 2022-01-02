//
//  Errors.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 02.03.2021.
//

import Foundation

enum Errors: Error, LocalizedError {
    case UnknownError
    case SignError
    case KeyValidationError
    case LoginTooSmall
    
    var errorDescription: String? {
        switch self {
        case .UnknownError:
            return NSLocalizedString("Unknown error", comment: "")
        case .SignError:
            return NSLocalizedString("Signature error", comment: "")
        case .KeyValidationError:
            return NSLocalizedString("Wrong key", comment: "")
        case .LoginTooSmall:
            return NSLocalizedString("Login too small", comment: "")
        }
    }
}
