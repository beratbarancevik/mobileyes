//
//  MasterViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import AVFoundation
import UIKit

class MasterViewController: UIViewController {
    
    // MARK: - UI Variables

    @IBOutlet weak var speakButton: UIButton!
    
    // MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        speakButton.addTarget(self, action: #selector(speakButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - User Interaction Functions
    
    @objc private func speakButtonTapped() {
        let string = "Hello, World!"
        let utterance = AVSpeechUtterance(string: string)
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
