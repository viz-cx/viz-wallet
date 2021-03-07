//
//  AccountMetadata.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 07.03.2021.
//

import Foundation

struct AccountMetadata: Decodable {
    struct Profile: Decodable {
        let nickname: String?
        let about: String?
        let avatar: String?
    }
    let profile: Profile
}
