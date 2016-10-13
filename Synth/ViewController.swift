//
//  ViewController.swift
//  Synth
//
//  Created by Federico on 13/10/2016.
//  Copyright © 2016 Federico. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var pitchSlider: UISlider! {
        didSet {
            pitchSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        }
    }
    @IBOutlet weak var fineSlider: UISlider! {
        didSet {
            fineSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        }
    }
    
    @IBOutlet weak var currentOctaveLabel: UILabel!

    var oscillator = AKOscillator(
        waveform: AKTable(.square, size: 16),
        frequency: 261.6,
        amplitude: 0.1)
    var currentOctave = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioKit.output = oscillator
        AudioKit.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didChangeOctave(_ sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            let octave = stepper.value
            let difference = octave - currentOctave
            
            currentOctave = octave
            currentOctaveLabel.text = "\(currentOctave)"
            if difference > 0 {
                oscillator.frequency *= 2
            }
            else {
                oscillator.frequency /= 2
            }
        }
    }
    
    @IBAction func didChangeWaveform(_ sender: AnyObject) {
        
    }
    
    let baseOctaveFrequency = 61.74
    @IBAction func didChangePitch(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let p = slider.value - 11
            let f = pow(pow(2, (1/12)), p) * (baseOctaveFrequency * pow(2, (currentOctave + 2)))
            oscillator.frequency = f
        }
    }
    
    @IBAction func didChangeFinePitch(_ sender: AnyObject) {
        
    }
    
    @IBAction func didPressPlay(_ sender: AnyObject) {
        oscillator.start()
    }
    
    @IBAction func didPressStop(_ sender: AnyObject) {
        oscillator.stop()
    }
}

