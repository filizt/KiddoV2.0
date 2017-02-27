//
//  SegmentedControl.swift
//  Kiddo
//
//  Created by Filiz Kurban on 1/31/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

protocol CustomSegmentedControlDelegate: class {
    func didSelectItem(sender: CustomSegmentedControl, selectedIndex: Int)
}

@IBDesignable class CustomSegmentedControl: UIControl {

    private var labels = [UILabel]()
    private var selectionBar = UIView()
    private let SELECTION_BAR_HEIGHT: CGFloat = 3.0
    weak var delegate:CustomSegmentedControlDelegate?

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
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }


    //setup segmented control UI
    private func setupViews() {
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = UIColor.white

        setupSubviews()
    }

    //create to labels and selectionBar; add them to view
    private func setupSubviews() {
        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepingCapacity: true)

        var labelFrame = createNextLabelFrame(nil)
        for index in 0..<items.count {
            let label = UILabel(frame: labelFrame)
            label.text = items[index]
            label.backgroundColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Heavy", size: 14)
            label.textColor = UIColor(red:0.25, green:0.18, blue:0.35, alpha:1.0)

            self.addSubview(label)
            labels.append(label)

            labelFrame = createNextLabelFrame(label.frame)
        }

        //setup selectionBar
        selectionBar.frame =  createSelectionBarFrame(labels[selectedIndex].frame)
        selectionBar.backgroundColor = UIColor(red:0.25, green:0.18, blue:0.35, alpha:1.0)

        self.addSubview(selectionBar)
    }

    private func createNextLabelFrame(_ currentFrame: CGRect?) -> CGRect {
        let xOffset:CGFloat = 15.0
        let labelWidth = (self.bounds.size.width - (xOffset * 2)) / CGFloat(items.count)
        var newLabelFrame:CGRect

        if let currentFrame = currentFrame {
            let x = currentFrame.origin.x + currentFrame.size.width
            newLabelFrame  = CGRect(x: x, y: 0, width: labelWidth, height: self.frame.size.height)
        } else { //It's the first call
            newLabelFrame = CGRect(x: xOffset, y: 0, width: labelWidth, height: self.frame.size.height)
        }

        return newLabelFrame
    }

    private func createSelectionBarFrame(_ originFrame: CGRect) ->CGRect {
        var selectionBarFrame = originFrame
        selectionBarFrame.size.height = SELECTION_BAR_HEIGHT
        selectionBarFrame.origin.y = self.frame.size.height - SELECTION_BAR_HEIGHT

        return selectionBarFrame
    }

    override func layoutSubviews() {
        self.setupSubviews()
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

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseIn , animations: {
            self.selectionBar.frame = self.createSelectionBarFrame(label.frame)
        } , completion: { (complete: Bool) in
            if complete {
                self.delegate?.didSelectItem(sender: self, selectedIndex: self.selectedIndex)
            }
        })
    }
}




