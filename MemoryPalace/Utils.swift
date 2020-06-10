//
//  Utils.swift
//  MemoryPalace
//
//  Copyright © 2020 Gareth George and Dana Nguyen. All rights reserved.
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
