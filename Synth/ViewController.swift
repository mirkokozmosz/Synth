//
//  ViewController.swift
//  Synth
//
//  Created by Federico on 13/10/2016.
//  Copyright © 2016 Federico. All rights reserved.
//

import UIKit
import AudioKit

extension UISlider {
    func flip() {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var pitchSlider: UISlider! {
        didSet {
            pitchSlider.flip()
        }
    }
    @IBOutlet weak var fineSlider: UISlider! {
        didSet {
            fineSlider.flip()
        }
    }
    @IBOutlet weak var cutoffSlider: UISlider! {
        didSet {
            cutoffSlider.flip()
        }
    }
    
    @IBOutlet weak var resonanceSlider: UISlider! {
        didSet {
            resonanceSlider.flip()
        }
    }
    
    @IBOutlet weak var distortionSlider: UISlider! {
        didSet {
            distortionSlider.flip()
        }
    }

    @IBOutlet weak var currentOctaveLabel: UILabel!
    
    var oscillator = AKOscillator(
        waveform: AKTable(.square, size: 16),
        frequency: 261.6,
        amplitude: 0.1)
    var currentOctave = 0.0
    var filter:AKRolandTB303Filter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilter()
        
        AudioKit.output = filter
        AudioKit.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFilter() {
        filter = AKRolandTB303Filter(oscillator)
        filter?.cutoffFrequency = 10000
        filter?.distortion = 0
        filter?.resonance = 2.0 / 24.0
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
    
    @IBAction func didChangeCutoff(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let max = 10000.0
            let total = max / 24.0
            self.filter?.cutoffFrequency = slider.value * total
        }
    }
    
    @IBAction func didChangeResonance(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let max = 2.0
            let total = max / 24.0
            self.filter?.resonance = slider.value * total
        }
    }
    
    @IBAction func didChangeDistortion(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let max = 4.0
            let total = max / 24.0
            self.filter?.distortion = slider.value * total
        }
    }
    
    
}

