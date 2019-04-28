//
//  MainViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import ARKit
import AVFoundation
import CoreMedia
import Speech
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
        requestTranscribePermissions()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(screenTapped))
        view.addGestureRecognizer(gestureRecognizer)
        
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGR.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGR)
        
        sayIntroduction()
        sayTutorial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        minConfidence = UserDefaults.standard.float(forKey: "Mobileyes.Settings.Confidence")
        print("Min conf: \(minConfidence)")
        
        speechSpeed = UserDefaults.standard.float(forKey: "Mobileyes.Settings.Speech")
        print("Speech speed: \(speechSpeed)")
        
        initAR()
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
    
    
    
    
    
    // MARK: - Speech
    
    private func sayIntroduction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let utterance = AVSpeechUtterance(string: "Welcome to Mobilize")
            print("Welcome to Mobilize")
            utterance.rate = self.speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    private func sayTutorial() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            let utterance = AVSpeechUtterance(string: "Tap and hold for voice commands")
            print("Tap and hold for voice commands")
            utterance.rate = self.speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    private func initAR() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            if ARConfiguration.isSupported {
                self.startSession()
            } else {
                self.showError(with: "Your device does not support augmented reality :(")
            }
        }
    }

    
    
    
    
    
    
    
    
    
    // MARK: - Vision classification
    
    // Vision classification request and model
    /// - Tag: ClassificationRequest
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Instantiate the model from its generated Swift class.
            let model = try VNCoreMLModel(for: MobileNetV2_SSDLite().model)
            let request = VNCoreMLRequest(
                model: model,
                completionHandler: { [weak self] request, error in
                    self?.processObservations(for: request, error: error)
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
        
        if let _ = currentBuffer {
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
    }
    
    // Classification results
    var identifierString = ""
    var confidence: VNConfidence = 0.0
    
    var speechQueue = [String]()
    
    var minConfidence: Float = 0.5
    var speechSpeed: Float = 0.5
    
    private func addToQueueCond(_ word: String) {
        if !speechQueue.contains(word) {
            speechQueue.append(word)
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if !self.stopGuessing {
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    for result in results {
                        for label in result.labels {
                            if label.confidence > self.minConfidence {
                                let width = self.view.bounds.width
                                let height = width * 16 / 9
                                let offsetY = (self.view.bounds.height - height) / 2
                                let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                                let transform = CGAffineTransform(scaleX: 1, y: -1)
                                    .translatedBy(x: 0, y: -height - offsetY)
                                let rect = result.boundingBox.applying(scale).applying(transform)
                                print(label.confidence)
                                self.sayTheWords(label.identifier, rect)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Speech
    
    var isSettingsSaid = false
    
    private func saySettingsIntro() {
        if isSettingsSaid {
            let utterance = AVSpeechUtterance(string: "Settings, say confidence or speed")
            print("Settings")
            utterance.rate = self.speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    var searchWord: String?
    
    private func sayTheWords(_ word: String, _ rect: CGRect) {
        if searchWord?.lowercased() == word || searchWord == nil {
            let leftX = view.frame.width / 3
            let rightX = view.frame.width / 3 * 2
            
            let upY = view.frame.height / 3
            let downY = view.frame.height / 3 * 2
            
            let objectX = rect.origin.x
            let objectY = rect.origin.y
            
            var locationWord = ""
            
            if (rect.size.width <= leftX) && (rect.size.height <= upY) {
                if objectY < upY {
                    locationWord = " is at the top"
                } else if objectY > downY {
                    locationWord = " is at the bottom"
                }
                
                if objectX < leftX {
                    if locationWord.contains("is") {
                        locationWord += " left"
                    } else {
                        locationWord += " is on the left"
                    }
                } else if objectX > rightX {
                    if locationWord.contains("is") {
                        locationWord += " right"
                    } else {
                        locationWord += " is on the right"
                    }
                }
            }
            
            
            
            let utterance = AVSpeechUtterance(string: word + locationWord)
            utterance.rate = speechSpeed
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
            
            
            print(word + locationWord)
//            print(rect.origin.x)
//            print(view.frame.midX)
//            print(rect.origin.y)
//            print(view.frame.midY)
        }
    }
    
    
    
    
    
    
    // MARK: - Speech to Text
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    return
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        // start recognition!
        recognizer?.recognitionTask(with: request) { (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
            }
        }
    }
    
    var stopGuessing = false
    
    let notification = UINotificationFeedbackGenerator()
    
    @objc private func screenTapped(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            notification.notificationOccurred(.success)
            print("BEGAN")
            stopGuessing = true
            startRecording()
        case .ended:
            notification.notificationOccurred(.error)
            stopGuessing = false
            endRecording()
        default:
            break
        }
    }
    
    @objc private func doubleTapped(recognizer: UITapGestureRecognizer) {
        notification.notificationOccurred(.warning)
        searchWord = nil
        isSettingsSaid = false
    }
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var audioSession = AVAudioSession.sharedInstance()
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            
            var isFinal = false
            
            if result != nil {
                
                print(result?.bestTranscription.formattedString ?? "")
                isFinal = (result?.isFinal)!
                
                self.searchWord = result?.bestTranscription.formattedString
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func endRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        
        
        audioEngine.inputNode.reset()
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.soloAmbient)
            try audioSession.setMode(.spokenAudio)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        
        
        // settings
        if let searchWord = searchWord {
            switch searchWord.lowercased() {
            case "settings":
                isSettingsSaid = true
                saySettingsIntro()
                return
            case "speed":
                saySpeedHelp()
                return
            case "increase", "up":
                upSpeed()
                return
            case "decrease", "down":
                downSpeed()
                return
            default:
                sayError()
                break
            }
        }
        
        
        if !isSettingsSaid {
            if let word = searchWord, word != "" {
                let utterance = AVSpeechUtterance(string: "Looking for \(searchWord ?? "")")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
        }
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
