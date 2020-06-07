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
    
    var pageController: PageViewController!;
    
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
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
