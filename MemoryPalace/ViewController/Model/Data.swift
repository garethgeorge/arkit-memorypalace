//
//  Data.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/22/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import ARKit
import UIKit


// memory marker data type
// TODO: split memory marker value type and MemoryMarkerController type which should manage the lifecycle

class MemoryMarker: Codable {
    var id: String;
    var question: String;
    var answer: String;
    var color: CodableColor;
    
    // TODO: these fields need to not be serialized
    var markerView: UIView?;
    var anchor: ARAnchor?;
    
    init(id: String, question: String, answer: String) {
        self.id = id;
        self.question = question;
        self.answer = answer;
        self.color = CodableColor(color: .red);
    }
    
    func isValid() -> Bool {
        return question.trimmingCharacters(in: .whitespaces) != "" && answer.trimmingCharacters(in: .whitespaces) != "";
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, question, answer, color
    }
};

// struct to hold the app data
struct AppData: Codable {
    // an array of memory markers used by the app
    var palaceName: String = "";
    var memoryMarkers: [MemoryMarker] = [];
}


class AppDataController {
    private var appData: AppData;
    public var savedPalaces: [String] = [];
    static var global: AppDataController!;
    
    init(appData: AppData) {
        self.appData = appData;
        
        do {
            let savedPalacesData = try Data(contentsOf: self.getUrlForFile(name: ".savedpalaces"));
            self.savedPalaces = try JSONDecoder().decode([String].self, from: savedPalacesData);
            print("LOADED SAVED PALACES: ", savedPalaces);
        } catch {
            self.savedPalaces = [];
        }
    }
    
    func getPalaceName() -> String {
        return appData.palaceName;
    }
    
    func setPalaceName(name: String) {
        appData.palaceName = name;
    }
    
    func serializeAppData() throws -> String  {
        // serializes the appdata
        let encoder = JSONEncoder();
        let data = try encoder.encode(self.appData);
        return String(data: data, encoding: .utf8)!;
    }
    
    // functions to add memory markers and manage them
    func addMemoryMarker(question: String, answer: String) -> MemoryMarker {
        let newMarker = MemoryMarker(id: UUID().uuidString, question: question, answer: answer);
        self.appData.memoryMarkers.append(newMarker);
        NotificationCenter.default.post(name: .memoryMarkerAdded, object: newMarker);
        return newMarker;
    }
    
    func removeMemoryMarker(marker: MemoryMarker) {
        appData.memoryMarkers.removeAll{$0.id == marker.id};
        NotificationCenter.default.post(name: .memoryMarkerRemoved, object: marker);
    }
    
    func getMemoryMarker(id: String) -> MemoryMarker? {
        guard let idx = appData.memoryMarkers.firstIndex(where: {$0.id == id}) else {
            return nil;
        }
        return appData.memoryMarkers[idx];
    }
    
    func getMemoryMarker(idx: Int) -> MemoryMarker {
        return appData.memoryMarkers[idx];
    }
    
    func getMemoryMarkerCount() -> Int {
        return appData.memoryMarkers.count;
    }
    
    func updateMemoryMarker(marker: MemoryMarker) {
        guard let existingIdx = appData.memoryMarkers.firstIndex(where: {$0.id == marker.id}) else {
            print("ERROR -- attempted to update marker that is not registered / valid");
            return;
        }
        
        appData.memoryMarkers[existingIdx] = marker;
        NotificationCenter.default.post(name: .memoryMarkerUpdated, object: marker);
    }
    
    func removeAllMarkers() {
        let oldMarkers = appData.memoryMarkers;
        appData.memoryMarkers = [];
        for marker in oldMarkers {
            NotificationCenter.default.post(name: .memoryMarkerRemoved, object: marker);
        }
    }
    
    func getUrlForFile(name: String) -> URL {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent(name)
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }
    
    func loadExperience(svc: SceneViewController, id: String) {
        do {
            let markerSaveURL = self.getUrlForFile(name: id + ".json");
            let jsonData = try Data(contentsOf: markerSaveURL, options: .mappedIfSafe);
            let loadedAppData = try JSONDecoder().decode(AppData.self, from: jsonData);
            self.removeAllMarkers();
            appData = loadedAppData;
            print("loadExperience read marker data: " + String(data: jsonData, encoding: .utf8)!);
        } catch {
            let alert = UIAlertController(title: "Load Error", message: "No available worldmap to load -- please create a few markers and save your world first", preferredStyle: .alert);
            svc.present(alert, animated: true, completion: nil);
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} );
            return;
        }
        
        let worldMap: ARWorldMap = {
            let mapSaveURL = self.getUrlForFile(name: id + ".map");
            guard let data = try? Data(contentsOf: mapSaveURL)
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        
        // Display the snapshot image stored in the world map to aid user in relocalizing.
        
        if let snapshotData = worldMap.snapshotAnchor?.imageData,
            let snapshot = UIImage(data: snapshotData) {
            svc.relocalizationImage.image = snapshot;
        } else {
            print("No snapshot image in world map")
        }
        
        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
        
        // fix associations
        for anchor in worldMap.anchors {
            guard let anchorName = anchor.name else {
                continue;
            }
            for marker in appData.memoryMarkers {
                if marker.id == anchorName {
                    marker.anchor = anchor;
                }
            }
        }
        
        for marker in appData.memoryMarkers {
            print("emitting .memoryMarkerAdded for newly loaded marker");
            NotificationCenter.default.post(name: .memoryMarkerAdded, object: marker);
            NotificationCenter.default.post(name: .memoryMarkerUpdated, object: marker);
        }
        
        // show the configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical];
        configuration.initialWorldMap = worldMap;
        svc.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors]);
    }
    
    func saveExperience(svc: SceneViewController, id: String) {
        do {
            let markerSaveURL = self.getUrlForFile(name: id + ".json");
            let jsonData = try JSONEncoder().encode(self.appData);
            try jsonData.write(to: markerSaveURL, options: [.atomic]);
            print("saveExperience wrote marker data: " + String(data: jsonData, encoding: .utf8)!);
        } catch {
            let alert = UIAlertController(title: "Save Error", message: "Can't save marker data: \(error.localizedDescription)", preferredStyle: .alert);
            svc.present(alert, animated: true, completion: nil);
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} );
            return ;
        }
        
        svc.sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else {
                    let alert = UIAlertController(title: "Save Error", message: "Could not get the current world map. Please reposition and try again.", preferredStyle: .alert);
                    svc.present(alert, animated: true, completion: nil);
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} );
                    return;
            }
            
            // Add a snapshot image indicating where the map was captured.
            guard let snapshotAnchor = SnapshotAnchor(capturing: svc.sceneView)
                else { fatalError("Can't take snapshot") }
            map.anchors.append(snapshotAnchor)
            
            do {
                let mapSaveURL = self.getUrlForFile(name: id + ".map");
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: mapSaveURL, options: [.atomic])
                
                let alert = UIAlertController(title: "Save Successful", message: "Your memory palace is successfully saved, tap load to restore it after closing the app", preferredStyle: .alert)
                svc.present(alert, animated: true, completion: nil);
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} );
                
                // finally save the manifest with the names of the save files
                if !(self.savedPalaces.contains(id)) {
                    self.savedPalaces.append(id);
                }
                try self.saveSavedPalacesList();
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    func saveSavedPalacesList() throws {
        let savedPalacesFile = self.getUrlForFile(name: ".savedpalaces");
        let jsonData = try JSONEncoder().encode(self.savedPalaces);
        try jsonData.write(to: savedPalacesFile, options: [.atomic]);
        print("saveSavedPalacesList wrote save file list: " + String(data: jsonData, encoding: .utf8)!);
    }
}

extension Notification.Name {
    static var memoryMarkerAdded: Notification.Name {
        return .init(rawValue: "MemoryMarkerAdded");
    }
    
    static var memoryMarkerRemoved: Notification.Name {
        return .init(rawValue: "MemoryMarkerRemoved");
    }
    
    static var memoryMarkerUpdated: Notification.Name {
        return .init(rawValue: "MemoryMarkerUpdated");
    }
}
