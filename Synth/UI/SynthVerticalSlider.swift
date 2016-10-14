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
class SynthVerticalSlider : UIControl {
    @IBInspectable public var minimumValue : Double = 0 {
        didSet {
            if value < minimumValue {
                value = minimumValue
            }
        }
    }
    @IBInspectable public var maximumValue : Double = 0 {
        didSet {
            if value > maximumValue {
                value = maximumValue
            }
        }
    }
    
    private var _value: Double = 0
    @IBInspectable public var value: Double {
        get {
            return _value
        }
        set (newValue) {
            _value = newValue
            self.sendActions(for: .valueChanged)
            
        }
    }
    
    @IBInspectable public var inactiveColor : UIColor! = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Drawing and graphics
    
    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()?.clear(rect)
        drawBackground()
        
        drawBackgroundBar()
        drawTintedBar()
        drawKnob()
    }
    
    private func drawBackground() {
        let backgroundRect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
        let bgPath = UIBezierPath(rect: backgroundRect)
        self.backgroundColor?.setFill()
        bgPath.fill()
    }
    
    private func drawBar(y: CGFloat, height: CGFloat, color: UIColor) {
        let size = self.frame.size
        let barPath = UIBezierPath(roundedRect: CGRect(x: (size.width - 4) / 2,
                                                       y: y,
                                                       width: 4,
                                                       height: height),
                                   cornerRadius: 4)
        color.setFill()
        barPath.fill()
    }
    
    private func drawBackgroundBar() {
        drawBar(y: 6,
                height: knobPositionFromValue(),
                color: self.inactiveColor)
    }
    
    private func drawTintedBar() {
        let knobPosition = knobPositionFromValue()
        drawBar(y: knobPosition,
                height: backgroundBarSize().height - knobPosition + 6,
                color: self.tintColor)
    }
    
    private func drawKnob() {
        let knob = UIBezierPath(roundedRect: CGRect(x: 0,
                                                    y: knobPositionFromValue(),
                                                    width: self.frame.size.width,
                                                    height: 12),
                                   cornerRadius: 4)
        UIColor.white.setFill()
        knob.fill()
    }
    
    // Returns the middle point of the knob
    private func knobPositionFromValue() -> CGFloat {
        let ratio = CGFloat((maximumValue - _value) / (maximumValue - minimumValue))
        let position = (backgroundBarSize().height * ratio)
        
        return position < 0 ? 0 : position
    }
    
    // MARK: Behaviour
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let size = backgroundBarSize()
            let location = touch.location(in: self)
            var relativeValue = Double(size.height - location.y) / Double(size.height) * maximumValue
            if (relativeValue < minimumValue) {
                relativeValue = minimumValue
            }
            else if relativeValue > maximumValue {
                relativeValue = maximumValue
            }
            value = Double(relativeValue)
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Helpers
    private func backgroundBarSize() -> CGSize {
        let height = self.frame.size.height - 12 // padding = height of the knob
        return CGSize(width: 4, height: height)
    }
    
    // MARK: Interface Builder stuff
    
    override func prepareForInterfaceBuilder() {
        
    }
}
