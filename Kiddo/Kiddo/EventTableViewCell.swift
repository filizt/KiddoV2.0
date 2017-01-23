//
//  EventTableViewNib.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventVenueName: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!

    var event: Event? {
        didSet {
            updateUI()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.eventImage?.image = nil
        self.eventTitle?.text = nil
        self.eventVenueName?.text = nil
        self.eventStartTime?.text = nil
    }

    private func updateUI() {
        //load new information from our event (if any)
        if let event = event {
            self.eventTitle?.text = event.title
            self.eventVenueName?.text = event.location
            self.eventStartTime?.text = event.allDayFlag ? "ALL DAY" : DateUtil.shared.shortTime(from:event.startDate!)

            if let image = SimpleCache.shared.image(key:event.imageURL!) {
                self.eventImage?.image = image
                return
            }

            //We don't have imageFile in the cache; let's retreive it. Event photo is a PFFile in this state
            if let imageFile = event.photo {
                imageFile.getDataInBackground(block: { (imageData, error) in
                    guard error == nil else {
                        print ("Error retrieving image data from Parse")
                        return
                    }
                    guard let imageData = imageData else { return }
                    guard let image = UIImage(data: imageData) else { return }
                    
                    SimpleCache.shared.setImage(image, key: event.imageURL!)
                    self.eventImage?.image = image
                })
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
