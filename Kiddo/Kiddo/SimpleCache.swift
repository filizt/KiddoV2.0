//
//  SimpleCache.swift
//  Kiddo
//
//  Created by Filiz Kurban on 1/19/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SimpleCache {
    static let shared = SimpleCache()

    private var cache = [String: UIImage]()
    var capacity = 300

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

    static func fetchImages(objects: [PFObject]) {
        let imageIds = Array(Set(objects.flatMap { $0["eventImageId"] as! String }))

        let query = PFQuery(className: "EventImage")
        query.whereKey("objectId", containedIn: imageIds )
        query.findObjectsInBackground(block: { (objects, error) in
            guard error == nil else {
                print ("Error retrieving image data from Parse")
                return
            }

            if let objects = objects {
                for object in objects {
                    guard let imageFile = object["image"] as? PFFile else { return }

                    imageFile.getDataInBackground({ (data, error) in
                        guard error == nil else {
                            print ("Error retrieving image data from Parse")
                            return
                        }
                        guard let imageData = data else { return }
                        guard let image = UIImage(data: imageData) else { return }

                        SimpleCache.shared.setImage(image, key: object.objectId!)

                    })
                }
            }
        })
    }
}
