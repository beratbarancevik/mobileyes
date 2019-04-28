//
//  Settings.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 28/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import AVFoundation

extension MainViewController {
    
    func sayError() {
        if isSettingsSaid {
            let utterance = AVSpeechUtterance(string: "Please try again")
            print("Please try again")
            utterance.rate = self.speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    func saySpeedHelp() {
        if isSettingsSaid {
            let utterance = AVSpeechUtterance(string: "This is speed, say up or down")
            print("Speed")
            utterance.rate = self.speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    func upSpeed() {
        if isSettingsSaid {
            let speechSetting = 0.6
            speechSpeed = 0.6
            UserDefaults.standard.set(speechSetting, forKey: "Mobileyes.Settings.Speech")
            UserDefaults.standard.synchronize()
            
            let utterance = AVSpeechUtterance(string: "Speed increased")
            print("Speed increased")
            utterance.rate = 0.6
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    func downSpeed() {
        if isSettingsSaid {
            let speechSetting = 0.5
            speechSpeed = 0.5
            UserDefaults.standard.set(speechSetting, forKey: "Mobileyes.Settings.Speech")
            UserDefaults.standard.synchronize()
            
            let utterance = AVSpeechUtterance(string: "Speed decreased")
            print("Speed decreased")
            utterance.rate = 0.5
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
}
