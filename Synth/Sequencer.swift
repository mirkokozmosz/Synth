//
//  Sequencer.swift
//  Synth
//
//  Created by Federico on 14/10/2016.
//  Copyright © 2016 Federico. All rights reserved.
//

import Foundation
import AudioKit

let START_TEMPO = 200.0

class Sequencer {
    let midi = AKMIDI()

    var sequence = AKSequencer()
    let sequenceLength = AKDuration(beats: 16.0)
    var melodicMIDI: AKMIDINode
    
    var currentTempo = START_TEMPO {
        didSet {
            sequence.setTempo(currentTempo)
        }
    }
    
    init(emitter: Emitter) {
        melodicMIDI = AKMIDINode(node: emitter)
        midi.addListener(emitter)
    }
    
    func addSequence() {
        let _ = sequence.newTrack()
        sequence.setLength(sequenceLength)
        sequence.tracks[0].setMIDIOutput(melodicMIDI.midiIn)
        
        for i in 0 ..< Int(sequenceLength.beats) {

            sequence.tracks[0].add(noteNumber: i,
                                   velocity: 100,
                                   position: AKDuration(beats: Double(i)),
                                   duration: AKDuration(beats: 1))
        }
        sequence.setLength(sequenceLength)
    }
    
    func play() {
        if (sequence.tracks.count > 0) {
            sequence.tracks[0].clear()
        }
        
        melodicMIDI.enableMIDI(midi.client, name: "melodicSound midi in")
        addSequence()
        
        sequence.enableLooping()
        sequence.setTempo(START_TEMPO)
        sequence.play()
    }
    
    func stop() {
        sequence.stop()
    }
}
