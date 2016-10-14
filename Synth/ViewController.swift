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

    @IBOutlet weak var pitchSlider: SynthVerticalSlider!
    @IBOutlet weak var fineSlider: SynthVerticalSlider!
    @IBOutlet weak var amplitudeSlider: SynthVerticalSlider!
    
    @IBOutlet weak var currentOctaveLabel: UILabel!
    
    var mixer : AKMixer?
    var emitter : Emitter?
    var filter:AKRolandTB303Filter?
    
    var previousPitchModifier : Double = 0
    var previousFinePitchModifier : Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        previousPitchModifier = self.pitchSlider.value
        previousFinePitchModifier = self.fineSlider.value
        
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
        emitter = Emitter(base: 61.74,
                          octave: 2,
                          waveform: AKTableType.square,
                          halfSteps: 0)
        if let oscillators = emitter?.oscillators {
            for (_, oscillator) in oscillators {
                oscillator.amplitude = amplitudeSlider.value
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
        if let slider = sender as? SynthVerticalSlider {
            emitter?.halfStepsModifier += (slider.value - previousPitchModifier)
            previousPitchModifier = slider.value
        }
    }
    
    @IBAction func didChangeFinePitch(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            emitter?.halfStepsModifier += (slider.value - previousFinePitchModifier)
            previousFinePitchModifier = slider.value
        }
    }
    
    @IBAction func didPressPlay(_ sender: AnyObject) {
        AudioKit.start()
    }
    
    @IBAction func didPressStop(_ sender: AnyObject) {
        AudioKit.stop()
    }
    
    @IBAction func didChangeCutoff(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            let max = 10000.0
            let total = max / 24.0
            self.filter?.cutoffFrequency = slider.value * total
        }
    }
    
    @IBAction func didChangeResonance(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            let max = 2.0
            let total = max / 24.0
            self.filter?.resonance = slider.value * total
        }
    }
    
    @IBAction func didChangeDistortion(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            let max = 4.0
            let total = max / 24.0
            self.filter?.distortion = slider.value * total
        }
    }
    
    @IBAction func didChangeAmplitude(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            emitter?.oscillator()?.amplitude = slider.value
        }
    }
    
}

