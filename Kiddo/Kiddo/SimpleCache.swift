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
    var capacity = 30

    func image(key: String) -> UIImage? {
        return self.cache[key]
    }

    func setImage(_ image:UIImage, key: String) {
        if self.cache.count >= self.capacity{
            guard let lastKey = Array(self.cache.keys).last else { return }
            self.cache.removeValue(forKey: lastKey)
        }
        cache[key] = image
    }
}
