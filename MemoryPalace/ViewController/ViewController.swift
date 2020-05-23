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
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
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
        let settingsPageController = UIViewController();
        pageController.addPage(page: settingsPageController);
        
        view.addSubview(pageController.view);
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let name = anchor.name else {
            return ;
        }
        if name == "memory" {
            // create a cursor sphere
            let sphere = SCNSphere(radius: 0.02);
            sphere.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1);

            let marker = SCNNode(geometry: sphere);
//            marker.position = SCNVector3(hitResult.columns.3.x, hitResult.columns.3.y, hitResult.columns.3.z);
            marker.categoryBitMask = 0b100;
            
            
            node.addChildNode(marker);
        }
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
            
            print("hit marker with anchor: " + anchor.name!);
            
            return;
        }
        
        
        let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any)!;
        guard let result = sceneView.session.raycast(query).first else {
            print("NO INTERSECTION / RESULT");
            return;
        }
        
        let anchor = ARAnchor(name: "memory", transform: result.worldTransform);
        sceneView.session.add(anchor: anchor);
//        sceneView.scene.rootNode.addChildNode(marker);
    }
}
