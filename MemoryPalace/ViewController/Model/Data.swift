//
//  Data.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/22/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation


// memory marker data type
class MemoryMarker: Codable {
    var id: String;
    var question: String;
    var answer: String;
    
    init(id: String, question: String, answer: String) {
        self.id = id;
        self.question = question;
        self.answer = answer;
    }
    
    
   func isValid() -> Bool {
       return question.trimmingCharacters(in: .whitespaces) != "" && answer.trimmingCharacters(in: .whitespaces) != "";
   }
       
};

// struct to hold the app data
struct AppData: Codable {
    // an array of memory markers used by the app
    var memoryMarkers: [MemoryMarker] = [];
}


class AppDataController {
    private var appData: AppData;
    static var global: AppDataController!;
    
    init(appData: AppData) {
        self.appData = appData;
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
