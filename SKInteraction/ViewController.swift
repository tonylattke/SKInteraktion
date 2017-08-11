//
//  ViewController.swift
//  SKInteraction
//
//  Created by Tony Lattke on 17.05.17.
//  Copyright © 2017 HSB. All rights reserved.
//

import UIKit
import SceneKit

// General Settings
let settings_numberOfGeometries: Int = 10
let settings_screenHorizontalLimit: Float = 6
let settings_cameraSpeed: Float = 0.1
let settings_moveSpeed: Float = 0.1

class ViewController: UIViewController {

    // View
    @IBOutlet weak var view3D: UIView!
    
    // Gestures
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var rotationGesture: UIRotationGestureRecognizer!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var buttonMode: UIButton!
    @IBOutlet weak var labelMode: UILabel!
    
    // World properties
    var sceneView: SCNView!
    let scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    
    let lightNode = SCNNode()
    let ambientLightNode = SCNNode()
    
    //
    var activeMaterial = SCNMaterial()
    var previousMaterial: [SCNMaterial] = []
    var selectedObject: SCNNode?
    
    var scaleFirstTime: Bool = true
    var rotationFirstTime: Bool = true
    
    var scaleActive: Float = 1
    var rotationActive: Float = 0
    
    var lookAt = SCNNode()
    
    var mode: AppMode = .camera
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Scene
        sceneView = SCNView(frame: self.view.frame, options:[SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.metal.rawValue)])
        view3D.addSubview(sceneView)
        sceneView.isPlaying = true
        sceneView.showsStatistics = true
        sceneView.scene = scene
        //sceneView.delegate = self
        
        // Set camera
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 12, z: 0)
        cameraNode.camera?.zFar = 1000
        cameraNode.camera?.zNear = 2
        cameraNode.camera?.xFov = 65
        cameraNode.camera?.yFov = 45
        scene.rootNode.addChildNode(self.cameraNode)
        
        lookAt.position = SCNVector3Zero
        
        let constraint = SCNLookAtConstraint(target: lookAt)
        constraint.isGimbalLockEnabled = false
        cameraNode.constraints = [constraint]
        
        // Light
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 50)
        scene.rootNode.addChildNode(lightNode)
        
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Plane
        let planeGeometry = SCNPlane(width: 50.0, height: 50.0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: 0, y: -0.5, z: 0)
        
        // Construct the tree
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(planeNode)
        
        // Generate random Geometry-nodes
        var i = 0 // Index
        while i < settings_numberOfGeometries {
            // Generate geometry
            let geometry: SCNGeometry = randomGeometry()
            let geometryNode = SCNNode(geometry: geometry)
            geometryNode.position.z = Float(i*2)
            geometryNode.position.x = Float.random(min:-settings_screenHorizontalLimit,
                                                   max:settings_screenHorizontalLimit) //(Float(arc4random()) / Float(UINT32_MAX)) * 5
            geometryNode.name = "editable object"
            
            // Generate material
            let material = SCNMaterial()
            material.diffuse.contents = randomColor()
            geometry.materials = [material]
   
            // Add geometry node to scene
            scene.rootNode.addChildNode(geometryNode)
            
            // Update index
            i += 1
        }
        
        buttonMode.titleLabel?.text = "Edition Mode"
        
        activeMaterial.diffuse.contents = UIColor.cyan
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleModeButton(_ sender: UIButton) {
        switch mode {
        case .camera:
            labelMode.text = "Current Mode: Edition"
            mode = .edition
        case .edition:
            labelMode.text = "Current Mode: Camera"
            mode = .camera
        }
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: sceneView)
        
        switch mode {
        case .camera:
            cameraNode.position = SCNVector3(cameraNode.position.x - Float(location.x)*settings_cameraSpeed,
                                             cameraNode.position.y,
                                             cameraNode.position.z - Float(location.y)*settings_cameraSpeed)
            lookAt.position = SCNVector3(cameraNode.position.x,
                                         0,
                                         cameraNode.position.z)
        case .edition:
            if selectedObject != nil {
                selectedObject?.position = SCNVector3((selectedObject?.position.x)! + Float(location.x)*settings_moveSpeed,
                                                      (selectedObject?.position.y)!,
                                                      (selectedObject?.position.z)! + Float(location.y)*settings_moveSpeed)
            }
        }
        sender.setTranslation(CGPoint(x: 0, y: 0), in: sceneView)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        switch mode {
        case .camera:
            print("Do nothing")
        case .edition:
            let location = sender.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)
            if hitResults.count > 0 {
                let result = hitResults.first!
                if result.node.name == "editable object" {
                    if selectedObject != nil {
                        // Restore color
                        activeMaterial = (selectedObject?.geometry?.materials.first)!
                        selectedObject?.geometry?.materials = previousMaterial
                        // Assign color
                        selectedObject = result.node
                        previousMaterial = (selectedObject?.geometry?.materials)!
                        selectedObject?.geometry?.materials = [activeMaterial]
                    } else {
                        selectedObject = result.node
                        previousMaterial = (selectedObject?.geometry?.materials)!
                        selectedObject?.geometry?.materials = [activeMaterial]
                    }
                    scaleActive = (selectedObject?.scale.x)!
                    //pinchGesture.scale = CGFloat(scaleActive)
                    rotationActive = (selectedObject?.rotation.w)!
                } else {
                    if selectedObject != nil {
                        // Restore color
                        activeMaterial = (selectedObject?.geometry?.materials.first)!
                        selectedObject?.geometry?.materials = previousMaterial
                        // Selected object nil
                        selectedObject = nil

                        scaleActive = 1
                        rotationActive = 0
                    }
                }
            }
        }

    }

    @IBAction func handleRotation(_ sender: UIRotationGestureRecognizer) {
        switch mode {
        case .camera:
            print("rotate camera")
        case .edition:
            if selectedObject != nil {
                if rotationFirstTime {
                    sender.rotation = CGFloat((selectedObject?.rotation.w)!)
                    rotationFirstTime = false
                }
                rotationActive = Float(sender.rotation)
                selectedObject?.pivot = SCNMatrix4Rotate(SCNMatrix4Identity, rotationActive, 0, 1, 0)
                if sender.state == .ended {
                    rotationFirstTime = true
                }
            }
        }
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch mode {
        case .camera:
//            cameraNode.scale = SCNVector3(cameraNode.position.x,
//                                             cameraNode.position.y +  Float(sender.scale),
//                                             cameraNode.position.z)
            print(sender.scale)
        case .edition:
            if selectedObject != nil {
                if scaleFirstTime {
                    sender.scale = CGFloat((selectedObject?.scale.x)!)//CGFloat(scaleActive)
                    scaleFirstTime = false
                } else {
                    scaleActive = Float(sender.scale)
                    selectedObject?.scale = SCNVector3(scaleActive,scaleActive,scaleActive)
                }
                if sender.state == .ended {
                    scaleFirstTime = true
                }
            }
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

