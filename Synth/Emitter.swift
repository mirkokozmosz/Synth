//
//  Tone.swift
//  Synth
//
//  Created by Nicolas Pepin-Perreault on 13/10/16.
//  Copyright © 2016 Federico. All rights reserved.
//

import Foundation
import AudioKit

class Emitter {
    var baseFrequency : Double = 0 {
        didSet {
            debugPrint("Setting baseFrequency to \(baseFrequency)")
            recalculateFrequency()
        }
    }
    var octave : Int = 0 {
        didSet {
            debugPrint("Setting octave to \(octave)")
            recalculateFrequency()
        }
    }
    var halfStepsModifier : Double = 0 {
        didSet {
            debugPrint("Setting halfStepsModifier to \(halfStepsModifier)")
            recalculateFrequency()
        }
    }
    private(set) var frequency : Double = 0
    private(set) var oscillators = [AKTableType:AKOscillator]()
    private var waveform : AKTableType
    
    init(base:Double, octave: Int, waveform: AKTableType = .square) {
        self.baseFrequency = base
        self.octave = octave
        
        oscillators[AKTableType.square] = AKOscillator(waveform: AKTable(.square), amplitude: 0.1)
        oscillators[AKTableType.triangle] = AKOscillator(waveform: AKTable(.triangle), amplitude: 0.1)
        
        self.waveform = waveform
        recalculateFrequency()
        self.oscillator()?.start()
    }
    
    func oscillator() -> AKOscillator? {
        return oscillators[waveform]
    }
    
    func changeWaveform(waveform: AKTableType) {
        self.oscillator()?.stop()
        self.waveform = waveform
        self.oscillator()?.start()
    }
    
    private func recalculateFrequency() {
        let baseStepFrequency = pow(2.0, 1.0/12.0)
        let octaveModifier = baseFrequency * pow(2.0, Double(octave))
        
        frequency = pow(baseStepFrequency, halfStepsModifier) * octaveModifier
        
        debugPrint("Setting frequency to \(frequency)")
        for (_, oscillator) in oscillators {
            oscillator.frequency = frequency
        }
    }
}