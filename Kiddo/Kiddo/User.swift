//
//  UserGraph.swift
//  Kiddo
//
//  Created by Filiz Kurban on 3/22/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

struct User {
    let id: String
    let first_name: String
    let last_name: String
    let full_name: String
    let email: String
    let gender: String
    let locale: String

    static var current: User?

    static func create(from userInfoDictionaryt: Any) -> User {
        var userInfo = userInfoDictionaryt as! Dictionary<String, Any>

        let id = userInfo["id"] as! String
        let first_name = userInfo["first_name"] as? String ?? ""
        let last_name = userInfo["last_name"] as? String ?? ""
        let full_name = userInfo["name"] as? String ?? ""
        let email = userInfo["email"] as? String ?? ""
        let gender = userInfo["gender"] as? String ?? ""
        let locale = userInfo["locale"] as? String ?? ""

        return User(id: id,
                    first_name: first_name,
                    last_name: last_name,
                    full_name: full_name,
                    email: email,
                    gender: gender,
                    locale: locale
                    )
    }
}
