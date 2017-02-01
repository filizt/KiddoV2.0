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
    private var selectionBar = UIView()

    var items: [String] = ["Item1","Item2"] {
        didSet {
            layoutSubviews()
        }
    }

    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupSubViews()
    }


    //update segmented controls UI; add thumbView to UI; call to create labels
    private func setupViews() {
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = UIColor.orange
    }

    private func setupSubViews() {
        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepingCapacity: true)

        //To-Do: Clean up below code.
        let xOffset:CGFloat = 15.0
        let labelWidth = (self.bounds.size.width - (xOffset * 2)) / CGFloat(items.count)
        var labelLocation = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.size.height)
        for index in 1...items.count {
            let label = UILabel(frame: labelLocation)
            label.text = items[index-1]
            label.backgroundColor = UIColor.orange
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir", size: 15)
            label.textColor = UIColor.white
            self.addSubview(label)
            labels.append(label)

            //update label location for the next label
            let x = label.frame.origin.x + label.frame.size.width + xOffset
            labelLocation  = CGRect(x: x, y: 0, width: labelWidth, height: self.frame.size.height)
        }

        //setup selectionBar
        var barFrame = labels[selectedIndex].frame
        barFrame.size.height = 3
        barFrame.origin.y = self.frame.size.height - barFrame.size.height
        selectionBar.frame =  barFrame
        selectionBar.backgroundColor = UIColor.white

        self.addSubview(selectionBar)
    }


    override func layoutSubviews() {
        self.setupSubViews()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                selectedIndex = index
                break
            }
        }

       /* if calculatedIndex != nil {
            selectedIndex = calculatedIndex! // this calls displayNewSelectedIndex to do the animation.
            sendActions(for: .valueChanged) // What does this do/trigger?
        }*/

        return false
    }

    private func displayNewSelectedIndex(){

        let label = labels[selectedIndex]

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.curveEaseIn , animations: {
            var labelFrame = label.frame
            labelFrame.size.height = 3
            labelFrame.origin.y = self.frame.size.height - labelFrame.size.height
            self.selectionBar.frame = labelFrame

        } , completion: nil)
        
        
    }
    
}


