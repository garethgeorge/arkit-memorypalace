//
//  MemoryListEditorViewController.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/23/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import UIKit

class MemMarkerListCell : UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class MemMarkerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public var markerTable: UITableView!;
    
    override func viewDidLoad() {
        print("CREATING UI TABLE VIEW!");
        markerTable = UITableView(frame: view.frame, style: .plain);
        markerTable.dataSource = self;
        markerTable.delegate = self;
        markerTable.register(MemMarkerListCell.self, forCellReuseIdentifier: "Cell");
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
        cell.detailTextLabel?.text = memoryMarker.answer;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print("TABLE VIEW TRYING TO SELECT ROW AT INDEX!");
        let editor = MemMarkerEditorViewController(marker: AppDataController.global.getMemoryMarker(idx: indexPath.row));
        present(editor, animated: true, completion: nil);
        
        return indexPath;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print("DELETING ROW IN TABLE");
            AppDataController.global.removeMemoryMarker(marker: AppDataController.global.getMemoryMarker(idx: indexPath.row));
        }
    }
}
