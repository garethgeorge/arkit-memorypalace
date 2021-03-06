//
//  SceneViewController.swift
//  MemoryPalace
//
//  Copyright © 2020 Gareth George and Dana Nguyen. All rights reserved.
//

import UIKit
import ARKit

class SceneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    public var sceneView: ARSCNView!
    
    private var statusLabel: UILabel!;
    private var sessionInfoLabel: UILabel!;
    private var canPlaceMarkers: Bool = false;
    
//    private var resetButton: UIButton!;
    private var saveLoadContainer: UIStackView!;
    private var saveButton: UIButton!;
    private var segmentedControl: UISegmentedControl!;
    private var loadButton: UIButton!;
    public var relocalizationImage: UIImageView!;

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.view.addSubview(sceneView);
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/empty.scn")!
        
        // setup the scene view
        sceneView.scene = scene
        sceneView.session.delegate = self
        sceneView.delegate = self;
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints];
        
        // add the relocalizationImageView
        relocalizationImage = UIImageView();
        relocalizationImage.layer.cornerRadius = 16;
        relocalizationImage.layer.masksToBounds = true;
        self.view.addSubview(relocalizationImage);
        
        // add the status label
        let labelBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.4);
        statusLabel = UILabel();
        statusLabel.numberOfLines = 0;
        statusLabel.backgroundColor = labelBackgroundColor;
        statusLabel.layer.cornerRadius = 8;
        statusLabel.layer.masksToBounds = true;
        statusLabel.textAlignment = .center;
        statusLabel.isHidden = true;
        self.view.addSubview(statusLabel);
        
        sessionInfoLabel = UILabel();
        sessionInfoLabel.numberOfLines = 0;
        sessionInfoLabel.backgroundColor = labelBackgroundColor;
        sessionInfoLabel.layer.cornerRadius = 8;
        sessionInfoLabel.layer.masksToBounds = true;
        sessionInfoLabel.textAlignment = .center;
        self.view.addSubview(sessionInfoLabel);
        
        // add save and load buttons
        saveLoadContainer = UIStackView();
        saveLoadContainer.axis = .horizontal;
        saveLoadContainer.alignment = .fill;
        saveLoadContainer.distribution = .fillEqually;
        saveLoadContainer.spacing = 5;
//        saveLoadContainer.addBackground(color: .white, alpha:0.3)

        
        self.view.addSubview(saveLoadContainer);
//        saveLoadContainer.backgroundColor?.withAlphaComponent(0.7);
        saveButton = RoundedButton();
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.addTarget(self, action: #selector(self.saveButtonTapped), for: .touchUpInside);
        saveLoadContainer.addArrangedSubview(saveButton);
        
        loadButton = RoundedButton();
        loadButton.setTitle("LOAD", for: .normal)
        loadButton.addTarget(self, action: #selector(self.loadButtonTapped), for: .touchUpInside);
        saveLoadContainer.addArrangedSubview(loadButton);
        
        
        // add gesture recognizer to sceneView
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSceneViewTap(_:)))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(singleTap)
        
        // segmented control for display mode
        segmentedControl = UISegmentedControl(frame: CGRect(x: 20, y: 50, width: self.view.frame.width - 40, height: 40));
        segmentedControl.backgroundColor = .clear
        segmentedControl.insertSegment(withTitle: "Memorize", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Quiz", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Test", at: 2, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = true
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged);

        self.view.addSubview(segmentedControl)

        
        NotificationCenter.default.addObserver(forName: .memoryMarkerRemoved, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            // remove the anchor if it is found
            for anchor in self.sceneView.session.currentFrame!.anchors {
                print("scanning anchors to process removal!");
                if anchor.name == marker.id {
                    self.sceneView.session.remove(anchor: anchor);
                }
            }
            
            // remove the associated view
            if let markerView = marker.markerView {
                markerView.removeFromSuperview();
            }
        });
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerAdded, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            let strokeTextAttributes: [NSAttributedString.Key : Any] = [
                .strokeColor : UIColor.black,
                .foregroundColor : UIColor.white,
                .strokeWidth : -2.0,
            ]
            
            let markerLabel = UILabel();
            markerLabel.attributedText = NSAttributedString(string: "Q: " + marker.question, attributes: strokeTextAttributes);
            marker.markerView = markerLabel;
            self.sceneView.addSubview(markerLabel);
        });
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerUpdated, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            if let anchor = marker.anchor, let node = self.sceneView.node(for: anchor) {
                // first remove current representation
                for cld in node.childNodes {
                    cld.removeFromParentNode();
                }
                
                // replace the sphere with one of the right color
                let sphere = SCNSphere(radius: 0.02);
                sphere.firstMaterial?.diffuse.contents = marker.color.color;
                let sphereNode = SCNNode(geometry: sphere);
                sphereNode.categoryBitMask = 0b100;
                
                node.addChildNode(sphereNode);
            }
            
            self.changeMarkerView();
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical];
        sceneView.session.run(configuration);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        self.sceneView.frame = self.view.frame;
        
        self.saveLoadContainer.frame = CGRect(x: 20, y: self.view.frame.height - 150, width: self.view.frame.width - 40, height: 50);
    
        self.relocalizationImage.frame = CGRect(x: 20, y: 50, width: self.view.frame.width * 0.4, height: self.view.frame.height * 0.4)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true;
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)";
        
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = [.horizontal, .vertical];
                self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors]);
                
                AppDataController.global.removeAllMarkers();
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        sessionInfoLabel.text = "Session was interrupted";
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        sessionInfoLabel.text = "Session interruption ended";
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.updateStatusLabels();
        
        // relocate all of the labels associated with the markers and whatnot
        for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
            let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
            
            if let anchor = marker.anchor {
                // do stuff with anchor
                
                let markerLocation = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z);
                let markerScrPos3 = sceneView.projectPoint(markerLocation); // z can be ignored, it is indicative of the depth of the pixel in the scene
                
                if let markerView = marker.markerView {
                    markerView.frame = CGRect(
                        x: CGFloat(markerScrPos3.x),
                        y: CGFloat(markerScrPos3.y),
                        width: markerView.frame.width,
                        height: markerView.frame.height
                    );
                }
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        self.updateStatusLabels();
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let name = anchor.name else {
            return ;
        }
        
        // only markers with id's are rendered
        guard let marker = AppDataController.global.getMemoryMarker(id: name) else {
            print("ERROR!!! renderer trying to render anchor for marker " + name + " but that marker was not found in memoryMarkers table");
            return;
        }
        
        // create a marker sphere
        let sphere = SCNSphere(radius: 0.02);
        sphere.firstMaterial?.diffuse.contents = marker.color.color;

        let sphereNode = SCNNode(geometry: sphere);
        sphereNode.categoryBitMask = 0b100;
        
        node.addChildNode(sphereNode);
    }
    
    // MARK - UIPageControl
    
    @objc func handleSceneViewTap(_ recognizer: UITapGestureRecognizer) {
        print("a new tap on the screen was detected!");
        let touchLocation = recognizer.location(in: sceneView);
        
        
        // first check if we can hit an existing memory marker, if so we will edit it
        if let result = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.categoryBitMask: 0b100]).first {
            print("we may have hit an existing marker...");
            
            guard let anchor = sceneView.anchor(for: result.node) else {
                print("uh oh... we couldn't get the anchor for that marker");
                return;
            };
            
            guard let markerId = anchor.name else {
                print("THIS SHOULD NEVER HAPPEN -- GOT A HIT, BUT NO ANCHOR.NAME WAS SET");
                return;
            }
            
            print("removing marker with id: " + markerId);
            guard let marker = AppDataController.global.getMemoryMarker(id: markerId) else {
                print("\tMARKER WITH THAT ID COULD NOT BE FOUND");
                return ;
            }
            
            let editor = MemMarkerEditorViewController(marker: marker, removeOnCancel: false);
            present(editor, animated: true, completion: nil);
            
            return;
        }
        
        if (!canPlaceMarkers) {
            let alert = UIAlertController(title: "Limited Tracking", message: "Markers should not be placed in limited tracking state, please move around a bit to better scan the area.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil);
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} );
            return;
        }
        
        // okay, we didn't hit an existing marker so lets check if we can create a new one
        let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any)!;
        guard let result = sceneView.session.raycast(query).first else {
            print("NO INTERSECTION / RESULT");
            return;
        }
        
        // we got a hit, create the marker
        let marker = AppDataController.global.addMemoryMarker(question: "", answer: "");
        
        // anchor needs to be created here to provide access to the result worldTransform
        let anchor = ARAnchor(name: marker.id, transform: result.worldTransform);
        marker.anchor = anchor;
        self.sceneView.session.add(anchor: anchor);
        
        let editor = MemMarkerEditorViewController(marker: marker, removeOnCancel: true);
        present(editor, animated: true, completion: nil);
    }
    
    private func updateStatusLabels() {
        guard let frame = sceneView.session.currentFrame else {
            return;
        }
        
        // update the status label and manage its layout
        statusLabel.text = """
        Mapping: \(frame.worldMappingStatus.description)
        Tracking: \(frame.camera.trackingState.description)
        """
        statusLabel.frame = CGRect(x: 0, y: 50, width: 200, height: 200);
        statusLabel.sizeToFit();
        var labelFrame = statusLabel.frame;
        labelFrame.size.width += 20;
        labelFrame.size.height += 20;
        statusLabel.frame = labelFrame;
        statusLabel.center.x = self.view.center.x;
        
        // update the canPlaceMarkers property
        switch frame.worldMappingStatus {
        case .mapped:
            canPlaceMarkers = true;
        default:
            canPlaceMarkers = false;
        }
        
        // update the sessionInfoLabel
        let message: String
        
        relocalizationImage.isHidden = true;
        switch (frame.camera.trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped):
            message = "Tap the screen to place a marker. Tap 'SAVE' to save your memory palace";
        case (.normal, _):
            message = "Move around to map the environment."
        case (.limited(.relocalizing), _):
            message = "Move your device to the location shown in the image."
            relocalizationImage.isHidden = false;
        default:
            message = frame.camera.trackingState.localizedFeedback
        }
        
        sessionInfoLabel.text = message
        sessionInfoLabel.isHidden = message.isEmpty
        sessionInfoLabel.sizeToFit();
        var sessionInfoLabelFrame = sessionInfoLabel.frame;
        sessionInfoLabelFrame.size.width += 20;
        sessionInfoLabelFrame.size.height += 20;
        sessionInfoLabel.frame = sessionInfoLabelFrame;
        sessionInfoLabel.center.x = self.view.center.x;
        sessionInfoLabel.center.y = self.view.frame.height - 200;
    }
    
    
    @objc func saveButtonTapped() {
        print("SAVE BUTTON TAPPED");
        var alert = UIAlertController(title: "Save File Name?", message: "Enter a save file name for this memory palace", preferredStyle: .alert);
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
            if AppDataController.global.getPalaceName().count > 0 {
                textField.text = AppDataController.global.getPalaceName()
            }
        })
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler:{ (alertAction:UIAlertAction!) in
            let textf = (alert.textFields?[0])! as UITextField
            guard let fileName = textf.text else {
                print("FAILED TO SAVE, NO FILENAME PROVIDED");
                return ;
            }
            
            AppDataController.global.setPalaceName(name: fileName);
            AppDataController.global.saveExperience(svc: self, id: fileName);
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func loadButtonTapped() {
        print("LOAD BUTTON TAPPED");
        let loadVc = MemoryPalaceListViewController();
        loadVc.svc = self;
        self.present(loadVc, animated: true, completion: nil);
    }
    
    func changeMarkerView(){
        if (self.segmentedControl.selectedSegmentIndex == 0){
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                   markerLabel.text = "\(markerIdx+1)\n" + "Hint: " + marker.question + "\n" + "Answer: " + marker.answer;
                   markerLabel.font = UIFont(name:"HelveticaNeue-Bold", size:16.0);
                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
                   markerLabel.backgroundColor = marker.color.color.withAlphaComponent(0.4);
                   markerLabel.sizeToFit();
                }
            }

        } else if(self.segmentedControl.selectedSegmentIndex == 1){
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                   markerLabel.text = "\(markerIdx+1)\n" + "Hint: " + marker.question;
                   markerLabel.font = UIFont(name:"HelveticaNeue-Bold", size:16.0);

                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
                   markerLabel.backgroundColor = marker.color.color.withAlphaComponent(0.4);
                   markerLabel.sizeToFit();
                }
            }
        } else {
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                   markerLabel.text = "\(markerIdx+1)";
                   markerLabel.font = UIFont(name:"HelveticaNeue-Bold", size:16.0);
                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
                   markerLabel.backgroundColor = marker.color.color.withAlphaComponent(0.4);
                   markerLabel.sizeToFit();
                }
            }
        }

    }
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print(self.segmentedControl.selectedSegmentIndex)
        self.changeMarkerView()
    }

}

extension UIStackView {
    func addBackground(color: UIColor, alpha: CGFloat) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.backgroundColor?.withAlphaComponent(alpha)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
