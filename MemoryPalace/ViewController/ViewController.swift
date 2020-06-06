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


class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var currentPlacement: SCNNode?
    
    var pageController: PageViewController!;
    
    var pages: [UIView]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the app data
        let appData = AppData();
        AppDataController.global = AppDataController(appData: appData);
        
        // create the pages
        pageController = PageViewController();
        view.addSubview(pageController.view);
        addChild(pageController);
        
        // scene view page and its controller
        let sceneViewController = SceneViewController();
        sceneViewController.sceneView = sceneView;
        pageController.addPage(page: sceneViewController);
        
        // currently empty memory manager page and its controller
        pageController.addPage(page: MemMarkerListViewController());
        
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
}
