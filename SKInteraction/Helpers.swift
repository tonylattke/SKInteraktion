//
//  Helpers.swift
//  SKInteraction
//
//  Created by Tony Lattke on 17.05.17.
//  Copyright © 2017 HSB. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

public enum AppMode:Int {
    case camera = 0
    case edition
}

public enum ShapeType:Int {
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    static func random() -> ShapeType {
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}

public enum ColorType:Int {
    case red = 0
    case green
    case blue
    case orange
    
    static func random() -> ColorType {
        let maxValue = orange.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ColorType(rawValue: Int(rand))!
    }
}

func randomGeometry() -> SCNGeometry {
    var geometry:SCNGeometry
    switch ShapeType.random() {
    case .box:
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
    case .sphere:
        geometry = SCNSphere(radius: 0.5)
    case .pyramid:
        geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
    case .torus:
        geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
    case .capsule:
        geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
    case .cylinder:
        geometry = SCNCylinder(radius: 0.3, height: 2.5)
    case .cone:
        geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
    case .tube:
        geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
    }
    return geometry
}

func randomColor() -> UIColor {
    var color: UIColor
    switch ColorType.random() {
    case .blue:
        color = .blue
    case .green:
        color = .green
    case .red:
        color = .red
    case .orange:
        color = .orange
    }
    return color
}

//public extension Int {
//    /// Returns a random Int point number between 0 and Int.max.
//    public static var random:Int {
//        get {
//            return Int.random(Int.max)
//        }
//    }
//    /**
//     Random integer between 0 and n-1.
//     
//     - parameter n: Int
//     
//     - returns: Int
//     */
//    public static func random(n: Int) -> Int {
//        return Int(arc4random_uniform(UInt32(n)))
//    }
//    /**
//     Random integer between min and max
//     
//     - parameter min: Int
//     - parameter max: Int
//     
//     - returns: Int
//     */
//    public static func random(min: Int, max: Int) -> Int {
//        return Int.random(max - min + 1) + min
//        //Int(arc4random_uniform(UInt32(max - min + 1))) + min }
//    }
//}

public extension Double {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random number Double
     
     - parameter min: Double
     - parameter max: Double
     
     - returns: Double
     */
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

public extension Float {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random num Float
     
     - parameter min: Float
     - parameter max: Float
     
     - returns: Float
     */
    public static func random(min min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
