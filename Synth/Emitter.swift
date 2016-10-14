//
//  Tone.swift
//  Synth
//
//  Created by Nicolas Pepin-Perreault on 13/10/16.
//  Copyright © 2016 Federico. All rights reserved.
//

import Foundation
import AudioKit

class Emitter : AKPolyphonicNode, AKMIDIListener, StepSequencerDelegate {
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
    
    let output = AKMixer()
    
    var sequencer: Sequencer?
    
    init(base:Double, octave: Int, waveform: AKTableType = .square, halfSteps: Double, amplitude: Double) {
        self.baseFrequency = base
    
        self.octave = octave
        self.halfStepsModifier = halfSteps
        
        oscillators[AKTableType.square] = AKOscillator(waveform: AKTable(.square), amplitude: 0)
        oscillators[AKTableType.triangle] = AKOscillator(waveform: AKTable(.triangle), amplitude: 0)
        
        self.waveform = waveform
        
        super.init() // Don't ask...
        recalculateFrequency()
        self.oscillator()?.start()
        
        for (_, oscillator) in oscillators {
            oscillator.amplitude = amplitude
            output.connect(oscillator)
        }
        
        sequencer = Sequencer(emitter: self)

        output.start()
    }
    
    func oscillator() -> AKOscillator? {
        return oscillators[waveform]
    }
    
    func changeWaveform(waveform: AKTableType) {
        self.oscillator()?.stop()
        
        let previousAmplitude = self.oscillator()?.amplitude ?? 0.1
        
        self.waveform = waveform
        
        self.oscillator()?.amplitude = previousAmplitude
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
    
    func play() {
        sequencer?.play()
    }
    
    func stop() {
        sequencer?.stop()
    }
    
//Mark: AKNode
    
    override var avAudioNode: AVAudioNode {
        get {
            return output.avAudioNode
        }
        set(x) {
            output.avAudioNode = avAudioNode
        }
    }
    
    override func addConnectionPoint(_ node: AKNode) {
        output.addConnectionPoint(node)
    }
    
// MARK: AKMIDIListener
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        debugPrint("Received MIDI note on")
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        debugPrint("Received MIDI note off")
    }
    
//Mark: AKPolyphonicNode
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        debugPrint("play")
        if(steps[noteNumber]) {
            oscillator()?.play()
        }
        else {
            oscillator()?.stop()
        }
    }
    
    override func stop(noteNumber: MIDINoteNumber) {
        //debugPrint("stop")
        //oscillator()?.stop()
    }
    
    var steps = [Bool]()
    
//MARK: StepSequencerDelegate
    func didChangeStepStatus(_ stepIndex: Int, enabled: Bool) {
        steps[stepIndex] = enabled
    }

}
