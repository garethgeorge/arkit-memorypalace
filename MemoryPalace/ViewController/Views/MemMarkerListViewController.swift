//
//  MemoryListEditorViewController.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/23/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import UIKit

class MemMarkerListViewController: UIViewController, UITableViewDataSource {
    public var markerTable: UITableView!;
    
    override func viewDidLoad() {
        print("CREATING UI TABLE VIEW!");
        markerTable = UITableView(frame: view.frame, style: .plain);
        markerTable.dataSource = self;
        markerTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell");
        view.addSubview(markerTable);
        
        // on marker add / remove reload the table
        NotificationCenter.default.addObserver(forName: .memoryMarkerAdded, object: nil, queue: nil, using: {(object) in
            self.markerTable.reloadData();
        });
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerRemoved, object: nil, queue: nil, using: {(object) in
            self.markerTable.reloadData();
        });
        
        NotificationCenter.default.addObserver(forName: .memoryMarkerUpdated, object: nil, queue: nil, using: {(object) in
            self.markerTable.reloadData();
        });
    }
    
    override func viewDidLayoutSubviews() {
        markerTable.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height);
        markerTable.reloadData();
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDataController.global.getMemoryMarkerCount();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memoryMarker = AppDataController.global.getMemoryMarker(idx: indexPath.row);
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        cell.textLabel?.text = memoryMarker.question;
        return cell;
    }
}
