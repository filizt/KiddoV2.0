//
//  SpecialEvent.swift
//  Kiddo
//
//  Created by Filiz Kurban on 5/6/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import UIKit

class SpecialEvent {

    static let shared = SpecialEvent()

    var isEnabled = false
    var name = ""
    var sizeMultiplier:CGFloat = 1.0
}
