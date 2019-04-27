//
//  AddCustomObjectViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import ARKit
import UIKit

class AddCustomObjectViewController: UIViewController {
    
    // MARK: - UI Variables
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if ARConfiguration.isSupported {
            startSession()
        } else {
            showError(with: "Your device does not support augmented reality :(")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pauseScene()
    }
    
    // MARK: - Other View Controller Methods
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    // MARK: - AR Functions
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        sceneView.showsStatistics = true
    }
    
    private func startSession() {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            sceneView.session.run(configuration)
        } else {
            showError(with: "World tracking is not supported")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func pauseScene() {
        sceneView.session.pause()
    }
}
