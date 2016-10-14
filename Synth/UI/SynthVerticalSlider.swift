//
//  SynthVerticalSlider.swift
//  Synth
//
//  Created by Nicolas Pepin-Perreault on 14/10/16.
//  Copyright © 2016 Federico. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SynthVerticalSlider : UISlider {
    private func rotate() {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rotate()
        var frame = self.frame
        frame.size.height = self.frame.width
        frame.size.width = self.frame.height
        self.frame = frame
    }
    
    override func prepareForInterfaceBuilder() {
        rotate()
    }
}
