//
//  SimpleCache.swift
//  Kiddo
//
//  Created by Filiz Kurban on 1/19/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import UIKit

class SimpleCache {
    static let shared = SimpleCache()

    private var cache = [String: UIImage]()
    private let capacity = 8

    func image(key: String) -> UIImage? {
        return self.cache[key]
    }

    //what happens if there is a collusion here? Why is the Dictionary acting like a Set here. Need to look at the notes.
    func setImage(_ image:UIImage, key: String) {
        if self.cache.count >= self.capacity{
            guard let lastKey = Array(self.cache.keys).last else { return }
            self.cache.removeValue(forKey: lastKey)
        }
        cache[key] = image
    }
}
