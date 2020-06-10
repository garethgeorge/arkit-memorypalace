//
//  MemoryPalaceListViewController.swift
//  MemoryPalace
//
//  Copyright © 2020 Gareth George and Dana Nguyen. All rights reserved.
//

import Foundation
import UIKit


class MemoryPalaceListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var navBar: UINavigationBar!;
    private var doneButton: UIBarButtonItem!;
    private var memoryPalaceTable: UITableView!;
    private var selectedIndexPath: IndexPath?;
    public weak var svc: SceneViewController!;
    
    override func viewDidLoad() {
        view.layer.cornerRadius = 15.0;
        view.clipsToBounds = true;
        view.backgroundColor = .secondarySystemBackground;
        
        // setup the navbar
        navBar = UINavigationBar();
        
        let title = UINavigationItem(title: "Load Memory Palace");
        // set the done button
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneButtonPressed));
        doneButton.isEnabled = false;
        title.rightBarButtonItem = doneButton;
        navBar.setItems([title], animated: false);
        
        view.addSubview(navBar);
        
        memoryPalaceTable = UITableView(frame: view.frame, style: .plain);
        memoryPalaceTable.dataSource = self;
        memoryPalaceTable.delegate = self;
        memoryPalaceTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell");
        memoryPalaceTable.allowsSelection = true;
        memoryPalaceTable.allowsMultipleSelection = false;
        view.addSubview(memoryPalaceTable);
    }
    
    override func viewDidLayoutSubviews() {
        let parentFrame = view.superview!.frame
        let minDim = min(parentFrame.width, parentFrame.height) * 0.9;
        view.frame = CGRect(
            x: (parentFrame.width - minDim) / 2.0, y: minDim * 0.2,
            width: minDim, height: 200 + 60 + 10
        );
        
        navBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40);
        memoryPalaceTable.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: 200);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDataController.global.savedPalaces.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        cell.textLabel?.text = AppDataController.global.savedPalaces[indexPath.row];
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doneButton.isEnabled = true;
        selectedIndexPath = indexPath;
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        doneButton.isEnabled = false;
        selectedIndexPath = nil;
        return indexPath;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            AppDataController.global.savedPalaces.remove(at: indexPath.row);
            do {
                try AppDataController.global.saveSavedPalacesList();
            } catch {
                fatalError("failed to save the new saved palaces list");
            }
            self.memoryPalaceTable.deleteRows(at: [indexPath], with: .automatic);
        }
    }
    
    @objc func doneButtonPressed() {
        print("LoadMemoryPalace done button pressed");
        
        let idToLoad = AppDataController.global.savedPalaces[selectedIndexPath!.row];
        AppDataController.global.loadExperience(svc: svc, id: idToLoad);
        self.dismiss(animated: true, completion: nil);
    }
}
