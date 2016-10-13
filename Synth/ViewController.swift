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
    
    var mixer : AKMixer?
    var emitter : Emitter?
    var filter:AKRolandTB303Filter?
    
    var previousPitchModifier : Double = 0
    var previousFinePitchModifier : Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        previousPitchModifier = Double(self.pitchSlider.value)
        previousFinePitchModifier = Double(self.fineSlider.value)
        
        setupMixer()
        setupEmitter()
        setupFilter()
        
        AudioKit.output = filter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewConstraints()
    }
    
    func setupMixer() {
        mixer = AKMixer()
    }
    
    func setupEmitter() {
        emitter = Emitter(base: 61.74, octave: 2)
        if let oscillators = emitter?.oscillators {
            for (_, oscillator) in oscillators {
                mixer?.connect(oscillator)
            }
        }
        
        mixer?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFilter() {
        filter = AKRolandTB303Filter(mixer!)
        filter?.cutoffFrequency = 10000
        filter?.distortion = 0
        filter?.resonance = 2.0 / 24.0
    }
    
    @IBAction func didChangeOctave(_ sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            let octave = Int(stepper.value)
            currentOctaveLabel?.text = "\(octave)"
            emitter?.octave = octave + 2
        }
    }
    
    @IBAction func didChangeWaveform(_ sender: AnyObject) {
        if let segmentedControl = sender as? UISegmentedControl {
            if segmentedControl.selectedSegmentIndex == 0 {
                emitter?.changeWaveform(waveform: .square)
            }
            else {
                emitter?.changeWaveform(waveform: .triangle)
            }
        }
        
    }
    
    @IBAction func didChangePitch(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let currentModifier = Double(slider.value)
            emitter?.halfStepsModifier += (currentModifier - previousPitchModifier)
            previousPitchModifier = currentModifier
        }
    }
    
    @IBAction func didChangeFinePitch(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let currentModifier = Double(slider.value)
            emitter?.halfStepsModifier += (currentModifier - previousFinePitchModifier)
            previousFinePitchModifier = currentModifier
        }
    }
    
    @IBAction func didPressPlay(_ sender: AnyObject) {
        AudioKit.start()
    }
    
    @IBAction func didPressStop(_ sender: AnyObject) {
        AudioKit.stop()
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

