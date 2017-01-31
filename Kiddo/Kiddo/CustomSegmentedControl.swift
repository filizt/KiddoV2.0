//
//  SegmentedControl.swift
//  Kiddo
//
//  Created by Filiz Kurban on 1/31/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

@IBDesignable class CustomSegmentedControl: UIControl {

    private var labels = [UILabel]()
    var thumbView = UIView()

    var items: [String] = ["Item1","Item2","Item3"] {
        didSet {
            setupLabels()
        }
    }

    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }

    //update segmented controls UI; add thumbView to UI; call to create labels
    private func setupViews() {
        layer.cornerRadius = self.frame.height / 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        backgroundColor = UIColor.orange

        setupLabels()
        insertSubview(thumbView, at: 0)
    }

    //create labels
    private func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepingCapacity: true)

        for index in 1...items.count {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = items[index-1]
            label.backgroundColor = UIColor.orange
            label.textAlignment = .center
            self.addSubview(label)
            labels.append(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = UIColor.white
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }


        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged) // What does this do/trigger?
        }

        return false
    }

    func displayNewSelectedIndex(){
        /*  for (index, item) in labels.enumerated() {
         item.textColor = unselectedLabelColor
         }*/

        var label = labels[selectedIndex]
        //label.textColor = selectedLabelColor

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.repeat , animations: {
            self.thumbView.frame = label.frame
        } , completion: nil)
        
        
    }
    
}


