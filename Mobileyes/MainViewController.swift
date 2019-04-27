//
//  ViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import ARKit
import AVFoundation
import UIKit
import Vision

class MainViewController: UIViewController {
    
    // MARK: - UI Variables

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScene()
        initializeTabBar()
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
        self.navigationController?.navigationBar.isHidden = false
        
        pauseScene()
    }
    
    // MARK: - Other View Controller Methods
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    // MARK: - UI Set-Up Functions
    
    private func initializeTabBar() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.imageInsets = UIEdgeInsets.init(top: 5.5, left: 0, bottom: -5.5, right: 0)
            }
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

    // MARK: - Vision classification
    
    // Vision classification request and model
    /// - Tag: ClassificationRequest
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Instantiate the model from its generated Swift class.
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(
                model: model,
                completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
            })
            
            // Crop input images to square area at center, matching the way the ML model was
            // trained.
            request.imageCropAndScaleOption = .centerCrop
            
            // Use CPU for Vision processing to ensure that there are adequate GPU resources for
            // rendering.
            request.usesCPUOnly = true
            
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    var currentBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification requests
    let visionQueue = DispatchQueue(label: "com.mobileyes.Mobileyes.ARKitVision.serialVisionQueue")
    
    // Run the Vision+ML classifier on the current image buffer.
    /// - Tag: ClassifyCurrentImage
    func classifyCurrentImage() {
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the
        // orientation of the image with respect to device.
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        
        let requestHandler = VNImageRequestHandler(
            cvPixelBuffer: currentBuffer!,
            orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.classificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    // Classification results
    var identifierString = ""
    var confidence: VNConfidence = 0.0
    
    // Handle completion of the Vision request and choose results to display.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("Unable to classify image.\n\(error!.localizedDescription)")
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML
        // model in this project.
        let classifications = results as! [VNClassificationObservation]
        
        // Show a label for the highest-confidence result (but only above a minimum confidence
        // threshold).
        if let bestResult = classifications.first(where: { result in result.confidence > 0.5 }),
            let label = bestResult.identifier.split(separator: ",").first {
            identifierString = String(label)
            confidence = bestResult.confidence
        } else {
            identifierString = ""
            confidence = 0
        }
        
        guard !self.identifierString.isEmpty else {
            return // No object was classified.
        }
        
        print(String(
            format: "Detected \(self.identifierString) with %.2f",
            self.confidence * 100) + "% confidence")
        
        sayTheWords(self.identifierString)
        
//        DispatchQueue.main.async { [weak self] in
//            guard let name = self?.identifierString else {
//                return
//            }
            
//            self?.delegate?.foundObject(with: name)
//            self?.dismiss(animated: true, completion: nil)
//        }
    }
    
    // MARK: - Speech
    
    private func sayTheWords(_ words: String) {
        let utterance = AVSpeechUtterance(string: words)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

extension CGImagePropertyOrientation {
    init(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: self = .left
        case .landscapeLeft: self = .up
        case .landscapeRight: self = .down
        default: self = .right
        }
    }
}
