//
//  AddCustomObject+ARSessionDelegate.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import ARKit

extension AddCustomObjectViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
//            messageLabel.text = "Point to the item that you want to search"
            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            sceneView.session.run(configuration)
        case .limited(let reason):
            print("Limited tracking reason: \(reason)")
//            messageLabel.text = "Try moving your phone around"
        case .notAvailable:
            showError(with: "AR is not available :(")
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
        // anchors and nodes may be displaced if phone moves in this period
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session interruption ended")
        // optionally restart tracking
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARSession failed with: \(error.localizedDescription)")
    }
}
