//
//  FilterCollectionViewCell.swift
//  Kiddo
//
//  Created by Filiz Kurban on 11/13/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

protocol CellFilterButtonDelegate:NSObjectProtocol {
    func handleFilterButtonTap(selectedFilter: String)
}


class FilterCollectionViewCell: UICollectionViewCell {

    class var classReuseIdentifier: String { return "filterCollectionViewCell" }
    @IBOutlet weak var filterLabel: UILabel!
    weak var delegate: CellFilterButtonDelegate?

    override var isSelected: Bool {
        didSet {
            if isSelected {
                filterLabel.backgroundColor = UIColor.appPurpleColor
                filterLabel.textColor = UIColor.white
                filterLabel.layer.borderColor = UIColor.appPurpleColor.cgColor
                filterLabel.clipsToBounds = true
                delegate?.handleFilterButtonTap(selectedFilter: self.filterLabel.text!)
            } else {
                filterLabel.backgroundColor = UIColor.white
                filterLabel.textColor = UIColor.appPurpleColor
                filterLabel.layer.borderColor = UIColor.appPurpleColor.cgColor
            }
        }
    }

    func setFilterLabel(title: String) {
        //if title All then set it to selected
        filterLabel.text = title
        filterLabel.backgroundColor = UIColor.white
        filterLabel.textColor = UIColor.appPurpleColor
        filterLabel.layer.cornerRadius = 5
        filterLabel.layer.borderWidth = 0.5
        filterLabel.layer.borderColor = UIColor.appPurpleColor.cgColor

        //filterButton.addTarget(self, action: #selector(TimelineViewController.filterButtonPressed), for: UIControlEvents.touchUpInside)
        
    }

}
