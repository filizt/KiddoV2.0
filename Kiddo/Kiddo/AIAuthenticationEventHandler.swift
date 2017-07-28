//
//  File.swift
//  Kiddo
//
//  Created by Sergelenbaatar Tsogtbaatar on 7/28/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation

class AIAuthenticationEventHandler : NSObject, AIAuthenticationDelegate {
    init(name : String,
         fail: () -> Void,
         success: (APIResult!) -> Void) {
        eventHandlerName = name
        failHandler = fail
        successHandler = success
    }
    
    let eventHandlerName : String
    let failHandler : () -> Void
    let successHandler : (APIResult!) -> Void
    
    
    @objc func requestDidFail(errorResponse: APIError!) {
        NSLog("\(eventHandlerName) - \(errorResponse.error.message)")
        failHandler()
    }
    
    @objc func requestDidSucceed(apiResult: APIResult!) {
        NSLog("\(eventHandlerName) - \(apiResult.result)")
        successHandler(apiResult)
    }
}
