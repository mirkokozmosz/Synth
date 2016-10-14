//
//  ViewController.swift
//  Synth
//
//  Created by Federico on 13/10/2016.
//  Copyright © 2016 Federico. All rights reserved.
//

import UIKit
import AudioKit

protocol StepSequencerDelegate {
    func didChangeStepStatus(_ stepIndex: Int, enabled: Bool)
    var steps: [Bool] {set get}
}

class ViewController: UIViewController {

    @IBOutlet weak var pitchSlider: SynthVerticalSlider!
    @IBOutlet weak var fineSlider: SynthVerticalSlider!
    @IBOutlet weak var amplitudeSlider: SynthVerticalSlider!
    @IBOutlet weak var cutoffSlider: SynthVerticalSlider!
    @IBOutlet weak var resonanceSlider: SynthVerticalSlider!
    @IBOutlet weak var distortionSlider: SynthVerticalSlider!
    
    @IBOutlet weak var currentOctaveLabel: UILabel!
    
    var emitter : Emitter?
    var filter:AKRolandTB303Filter?
    
    var previousPitchModifier : Double = 0
    var previousFinePitchModifier : Double = 0
    
    var sequencerDelegate: StepSequencerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        previousPitchModifier = self.pitchSlider.value
        previousFinePitchModifier = self.fineSlider.value
        
        setup()
        
        AudioKit.output = filter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        emitter = Emitter(base: 61.74,
                          octave: 2,
                          waveform: AKTableType.square,
                          halfSteps: 0,
                          amplitude: amplitudeSlider.value)
        
        sequencerDelegate = emitter!
        sequencerDelegate?.steps = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]

        filter = AKRolandTB303Filter((emitter?.output)!)
        filter?.cutoffFrequency = cutoffSlider.value
        filter?.distortion = distortionSlider.value
        filter?.resonance = resonanceSlider.value
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
        emitter?.play()
        AudioKit.start()
    }
    
    @IBAction func didPressStop(_ sender: AnyObject) {
        emitter?.stop()
        AudioKit.stop()
    }
    
    @IBAction func didChangeCutoff(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            self.filter?.cutoffFrequency = slider.value
        }
    }
    
    @IBAction func didChangeResonance(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            self.filter?.resonance = slider.value
        }
    }
    
    @IBAction func didChangeDistortion(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            self.filter?.distortion = slider.value
        }
    }
    
    @IBAction func didChangeAmplitude(_ sender: AnyObject) {
        if let slider = sender as? SynthVerticalSlider {
            emitter?.oscillator()?.amplitude = slider.value
        }
    }
    
    @IBAction func didPressStep(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            button.isSelected = !button.isSelected
            sequencerDelegate?.didChangeStepStatus(button.tag,
                                                   enabled: button.isSelected)
            
        }
    }
    
}

