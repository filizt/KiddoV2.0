//
//  EventTableViewNib.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit
import Parse

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventVenueName: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventFreeImage: UIImageView!
    @IBOutlet weak var eventFeaturedLabel: UILabel!
    @IBOutlet weak var eventCategory: UIButton!
    @IBOutlet weak var eventFeaturedStar: UIImageView!

    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var dashBetweenTimes: UILabel!
    private let cache = SimpleCache.shared

    var event: Event? {
        didSet {
            updateUI()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.eventImage?.image = UIImage(named: "image_placeholder")
        self.eventTitle?.text = nil
        self.eventVenueName?.text = nil
        self.eventStartTime?.text = nil

    }

    private func updateUI() {
        //load new information from event object(if any)
        self.eventImage?.image = UIImage(named: "image_placeholder")
        self.eventCategory.layer.cornerRadius = 8
        self.eventCategory.layer.masksToBounds = true
        self.dashBetweenTimes.isHidden = true
        self.eventEndTime.isHidden = false
        self.eventFreeImage.isHidden = true

        if let event = event {
            self.eventTitle?.text = event.title
            self.eventVenueName?.text = event.location

            //allday flag and showTimes flags are mutually exclusive.
            //locationHours should still be saved as part of the data, as detail view relies on that to show "All Day" event's hours. This is needed for backward compatibility.
            if event.allDayFlag == true {
                self.dashBetweenTimes.isHidden = false
                self.eventStartTime?.text = "\(DateUtil.shared.shortTime(from:event.startTime))"
                self.eventEndTime?.text = "\(DateUtil.shared.shortTime(from:event.endTime))"
            } else {
                self.eventStartTime?.text = "\(DateUtil.shared.shortTime(from:event.startTime))"
                self.eventEndTime.isHidden = true
            }

            if let showTimes = self.event?.showTimes {
                self.eventStartTime?.text = showTimes
                self.eventEndTime.isHidden = true
            }

            if !event.ticketsURL.isEmpty {
                self.eventFreeImage.isHidden = false
                self.eventFreeImage.image = UIImage(named: "ticketsTimeline")
            } else {
                self.eventFreeImage.image = UIImage(named: "free")
                self.eventFreeImage.isHidden = event.freeFlag == true ? false : true
            }

            if event.category == "Other" {
                self.eventCategory.isHidden = true
            } else {
                self.eventCategory.isHidden = false
                self.eventCategory.isUserInteractionEnabled = false
                let formatedString = event.category.uppercased()
                self.eventCategory?.setTitle(formatedString, for: .normal)
                self.eventCategory.setBackgroundImage(UIImage(color: UIColor(red:1.00, green:0.83, blue:0.14, alpha:1.0)), for: UIControlState.normal)
            }

            if event.featuredFlag == true {
                self.eventFeaturedStar.isHidden = false
                self.eventFeaturedLabel.isHidden = false
            } else {
                self.eventFeaturedStar.isHidden = true
                self.eventFeaturedLabel.isHidden = true
            }


            if let image = cache.image(key:event.imageObjectId) {
                self.eventImage?.image = image
                return
            }

            //We don't have imageFile in the cache; let's retreive it from the server. Event photo is a PFFile in this state
            let eventIdForDownload = self.event?.id
            if !event.imageObjectId.isEmpty {
                let imageObjectId = event.imageObjectId
                let query = PFQuery(className: "EventImage")
                query.whereKey("objectId", equalTo: imageObjectId as Any)
                query.getFirstObjectInBackground(block: { (object, error) in
                    guard error == nil else {
                        print ("Error retrieving image data from Parse")
                        return
                    }

                    guard let object = object else { return }
                    guard let imageFile = object["image"] as? PFFile else { return }

                    imageFile.getDataInBackground({ (data, error) in
                        guard error == nil else {
                            print ("Error retrieving image data from Parse")
                            return
                        }
                        guard let imageData = data else { return }
                        guard let image = UIImage(data: imageData) else { return }

                        if let e = self.event {
                            if e.id == eventIdForDownload {
                                 self.eventImage?.image = image
                            }
                        }
                        self.cache.setImage(image, key: event.imageObjectId)
                    })
                })
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EventTableViewCell.handleTap(_:)))
//        self.eventFreeImage.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
