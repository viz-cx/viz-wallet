//
//  UserAuth.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import Combine

class UserAuth: ObservableObject {
    
    let objectWillChange = PassthroughSubject<UserAuth,Never>()
    
    func login() {
        // login request... on success:
        self.isLoggedin = true
    }
    
    var isLoggedin = false {
        didSet {
            objectWillChange.send(self)
        }
    }
}
