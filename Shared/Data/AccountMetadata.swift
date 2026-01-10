//
//  AccountMetadata.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/10/26.
//

import Foundation

struct AccountMetadata: Codable {
    let profile: Profile
    
    struct Profile: Codable {
        let nickname: String?
        let about: String?
        let gender: String?
        let avatar: String?
        let location: String?
        let interests: [String]?
        let site: String?
        let services: Services?
        
        struct Services: Codable {
            let telegram: String?
        }
    }
}

func parseAccountMetadata(from jsonString: String) throws -> AccountMetadata {
    guard let jsonData = jsonString.data(using: .utf8) else {
        throw Errors.KeyValidationError
    }
    return try JSONDecoder().decode(AccountMetadata.self, from: jsonData)
}

