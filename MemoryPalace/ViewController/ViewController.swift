//
//  ViewController.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/19/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var currentPlacement: SCNNode?
    
    var pageController: PageViewController!;
    
    var pages: [UIView]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // setup the app data
        let appData = AppData();
        AppDataController.global = AppDataController(appData: appData);
        
        // setup the scene view (todo: make a new controller for the scene view)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/empty.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints];
        
        // add gesture recognizer to sceneView
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSceneViewTap(_:)))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(singleTap)
        
        // create the pages
        pageController = PageViewController();
        view.addSubview(pageController.view);
        addChild(pageController);
        
        // scene view page and its controller
        let sceneViewController = UIViewController();
        sceneViewController.view = sceneView;
        pageController.addPage(page: sceneViewController);
        
        // currently empty memory manager page and its controller
        pageController.addPage(page: MemMarkerListViewController());
        
        view.addSubview(pageController.view);
        
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
            markerLabel.sizeToFit();
        });
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerUpdated, object: nil, queue: nil, using: {(notification) in
            guard let marker = notification.object as? MemoryMarker else {
                print("notification object was not a memory marker... :(");
                return
            }
            
            if let markerLabel = marker.markerView as? UILabel {
                markerLabel.text = "Q: " + marker.question;
                markerLabel.sizeToFit();
            }
        });
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]; // find horizontal and vertical surfaces

        // Run the view's session
        sceneView.session.run(configuration);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
}
