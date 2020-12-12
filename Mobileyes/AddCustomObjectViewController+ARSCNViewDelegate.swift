//
//  AddCustomObjectViewController+ARSCNViewDelegate.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import ARKit
import SceneKit

extension AddCustomObjectViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers
        // for analysis would starve the camera.
//        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
//            return
//        }
        
        // Retain the image buffer for Vision processing.
//        self.currentBuffer = frame.capturedImage
//        classifyCurrentImage()
    }
}
