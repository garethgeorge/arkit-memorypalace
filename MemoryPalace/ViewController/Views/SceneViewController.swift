//
//  SceneViewController.swift
//  MemoryPalace
//
//  Created by Gareth George on 6/6/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import UIKit
import ARKit
class Responder: NSObject {
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
    }
}
class SceneViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    public var sceneView: ARSCNView!
    private var segmentedControl: UISegmentedControl!;
    private var buttonBar: UIView!;
//    private var segmentControlIndex = 0;
//    public var segmentedController: SegmentedViewController!;

    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.view.addSubview(sceneView);
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/empty.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        sceneView.delegate = self;
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints];
        
        // add gesture recognizer to sceneView
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSceneViewTap(_:)))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(singleTap)
        
//        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
//        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: selectorWidth, height: 2))
////        selectorView.backgroundColor = selectorViewColor
//        self.sceneView.addSubview(selectorView)
        // add the subview
        segmentedControl = UISegmentedControl(frame: CGRect(x: 0, y: self.view.frame.height-100, width: self.view.frame.width, height: 40));
        segmentedControl.backgroundColor = .clear
//        segmentedControl.frame = CGRect(x:0, y:self.view.frame.height-150, width:self.view.frame.width, height:50);
//        segmentedControl.delegate = self;
        
        // Add segments
        segmentedControl.insertSegment(withTitle: "Learn (Q+A)", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Term  (Q)", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Definition (A)", at: 2, animated: true)
        // First segment is selected by default
        segmentedControl.selectedSegmentIndex = 0

        // This needs to be false since we are using auto layout constraints
        segmentedControl.translatesAutoresizingMaskIntoConstraints = true

        // Add the segmented control to the container view
        self.view.addSubview(segmentedControl)
        
//        segmentedControl.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
//        // Constrain the segmented control width to be equal to the container view width
//        segmentedControl.widthAnchor.constraint(equalTo: sceneView.widthAnchor).isActive = true
//        // Constraining the height of the segmented control to an arbitrarily chosen value
//        segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true

//        view.addSubview(segmentControl);
        
//        buttonBar = UIView()
//        // This needs to be false since we are using auto layout constraints
//        buttonBar.translatesAutoresizingMaskIntoConstraints = false
//        buttonBar.backgroundColor = UIColor.orange
        
        // Below view.addSubview(segmentedControl)
//        self.view.addSubview(buttonBar)
        
        let responder = Responder()
        segmentedControl.addTarget(responder, action: #selector(responder.segmentedControlValueChanged(_:)), for: .valueChanged)

        // Constrain the top of the button bar to the bottom of the segmented control
//        buttonBar.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor).isActive = true
//        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        // Constrain the button bar to the left side of the segmented control
//        buttonBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor).isActive = true
//        // Constrain the button bar to the width of the segmented control divided by the number of segments
//        buttonBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)).isActive = true
        
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerRemoved, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            // remove the anchor if it is found
            for anchor in self.sceneView.session.currentFrame!.anchors {
                print("scanning anchors to process removal!");
                //
                // NOTE: IN PROGRESS FOR TOMORROW, REMOVE ANCHOR COMPONENT WHEN ANCHOR IS REMOVED
                //
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
//            markerLabel.sizeToFit();
        });
        
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerUpdated, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            if let markerLabel = marker.markerView as? UILabel {
                self.changeMarkerView();
//                markerLabel.text = "Q: " + marker.question + "A: " + marker.answer;
//                markerLabel.numberOfLines = 0;
//                markerLabel.lineBreakMode = .byWordWrapping;
//                markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
//                markerLabel.sizeToFit();
//                markerLabel.sizeToFit();
            }
        });
    }
    
    override func viewDidLayoutSubviews() {
        self.sceneView.frame = self.view.frame;
    }
    
    // MARK: - ARSCNViewDelegate
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // TODO: properly handle error cases etc for a way to handle repositioning and whatnot :P
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let name = anchor.name else {
            return ;
        }
        
        // only markers with id's are rendered
        guard let marker = AppDataController.global.getMemoryMarker(id: name) else {
            print("ERROR!!! renderer trying to render anchor for marker " + name + " but that marker was not found in memoryMarkers table");
            return;
        }
        print("found marker for node: ", marker);
        
        // create a cursor sphere
        let sphere = SCNSphere(radius: 0.02);
        sphere.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1);

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
    func changeMarkerView(){
        if (self.segmentedControl.selectedSegmentIndex == 0){
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                   markerLabel.text = "Q: " + marker.question + "\n*****************\n" + "A: " + marker.answer;
                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
                   markerLabel.sizeToFit();
                }
            }
            
        } else if(self.segmentedControl.selectedSegmentIndex == 1){
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                    markerLabel.text = "Q: " + marker.question;
                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
                   markerLabel.sizeToFit();
                }
            }
        } else {
            for markerIdx in 0..<AppDataController.global.getMemoryMarkerCount() {
                let marker = AppDataController.global.getMemoryMarker(idx: markerIdx);
                if let markerLabel = marker.markerView as? UILabel {
                    markerLabel.text = "A: " + marker.answer;
                   markerLabel.numberOfLines = 0;
                   markerLabel.lineBreakMode = .byWordWrapping;
                   markerLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 200);
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
