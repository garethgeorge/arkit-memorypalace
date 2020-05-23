//
//  Utils.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/20/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}
func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x + r.x, l.y + r.y, l.z + r.z)
}

func * (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x * r.x, l.y * r.y, l.z * r.z)
}

func * (l: SCNVector3, r: SCNFloat) -> SCNVector3 {
    return SCNVector3Make(l.x * r, l.y * r, l.z * r)
}
