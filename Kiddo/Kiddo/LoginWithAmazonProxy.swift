//
//  LoginWithAmazonProxy.swift
//  Kiddo
//
//  Created by Sergelenbaatar Tsogtbaatar on 7/28/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import LoginWithAmazon

class LoginWithAmazonProxy {
    
    static let sharedInstance = LoginWithAmazonProxy()
    
    func login(delegate: AIAuthenticationDelegate) {
        AIMobileLib.authorizeUser(forScopes: Settings.Credentials.SCOPES, delegate: delegate, options: [])
    }
}
