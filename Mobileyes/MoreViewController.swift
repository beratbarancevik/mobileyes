//
//  MoreViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import AVFoundation
import UIKit

class MoreViewController: UIViewController {
    
    // MARK: - UI Variables

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var technologySegmentedControl: UISegmentedControl!
    @IBOutlet weak var confidenceSlider: UISlider!
    @IBOutlet weak var addCustomObjectButton: UIButton!
    
    // MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    // MARK: - Custom Functions
    
    private func initialize() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        addCustomObjectButton.layer.cornerRadius = 25
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func updateUI() {
        let technologySetting =
            UserDefaults.standard.integer(forKey: "Mobileyes.Settings.Technology")
        let confidenceSetting =
            UserDefaults.standard.float(forKey: "Mobileyes.Settings.Confidence")
        
        technologySegmentedControl.selectedSegmentIndex = technologySetting
        confidenceSlider.setValue(confidenceSetting, animated: true)
    }
    
    // MARK: - User Interaction Functions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Data Persistence
    
    private func saveSettings() {
        let technologySetting = technologySegmentedControl.selectedSegmentIndex
        UserDefaults.standard.set(technologySetting, forKey: "Mobileyes.Settings.Technology")
        
        let confidenceSetting = confidenceSlider.value
        UserDefaults.standard.set(confidenceSetting, forKey: "Mobileyes.Settings.Confidence")
        
        UserDefaults.standard.synchronize()
    }
    
    @objc func willResignActive(_ notification: Notification) {
        saveSettings()
    }
}
