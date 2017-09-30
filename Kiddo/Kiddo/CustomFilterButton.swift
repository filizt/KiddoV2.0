//
//  CustomFilterButton.swift
//  Kiddo
//
//  Created by Filiz Kurban on 9/7/17.
//  Copyright © 2017 Filiz Kurban. All rights reserved.
//

import UIKit

class CustomFilterButton: UIButton {

    //variable with getter and setter cannot have initial value ???
    override var isSelected: Bool {
        didSet {
            if isSelected {
                //update UI with custom params such as text color, background color
            } else {
                //update UI with custom params
            }

            self.setNeedsDisplay()
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if self.isSelected {
            var newRect = rect
            newRect.size.width = 3.0
            UIBezierPath(rect: newRect).fill()
        }else {
            var newRect = rect
            newRect.size.width = 3.0
            let path = UIBezierPath(rect: newRect)
            path.lineWidth = 3.0
            UIColor(white: 0.22, alpha: 0.5).set()
            path.stroke()
        }
    }


}
