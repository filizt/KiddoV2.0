//
//  UserGraph.swift
//  Kiddo
//
//  Created by Filiz Kurban on 3/22/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

//
//  Event.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import Foundation
import Parse

struct UserGraph {
    let id: String
    let first_name: String?
    let last_name: String?
    let email: String?
    let gender: String?
    let locale: String?

    static func create(from fbUserFetchResult: Any) -> UserGraph {
        var userGraphInfo = fbUserFetchResult as! Dictionary<String, Any>

        let id = userGraphInfo["id"] as! String
        let first_name = userGraphInfo["first_name"] as? String
        let last_name = userGraphInfo["last_name"] as? String
        let email = userGraphInfo["email"] as? String
        let gender = userGraphInfo["gender"] as? String
        let locale = userGraphInfo["locale"] as? String


        return UserGraph(id: id,
                         first_name: first_name,
                         last_name: last_name,
                         email: email,
                         gender: gender,
                         locale: locale
                        )
    }
}
