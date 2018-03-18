//
//  ViewController.swift
//  AR Ruler
//
//  Created by Wang, Zewen on 2018-03-18.
//  Copyright © 2018 Wang, Zewen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        //Can show the dots in the view of the device so that it will be easy to detect the scene
        //Options for drawing overlay content to aid debugging of AR tracking in a SceneKit view.
        //showFeaturePoints:Display a point cloud showing intermediate results of the scene analysis that ARKit uses to track device position.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Touch detected")
        if dotNodes.count>=2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addDot(at:hitResult)
            }
        
        }
    }
    func addDot(at hitResult: ARHitTestResult){
        // scnphere, material, node
        let dotGeometry = SCNSphere()
        dotGeometry.radius = 0.005
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode()
        dotNode.geometry = dotGeometry
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2{
            calculate()
        }
    }
    
    
    func calculate(){
        let start = dotNodes[0].position
        let end = dotNodes[1].position
        //xz-grid because we are facing xy surface
        let distance = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2) + pow(end.z - start.z, 2))
        print(distance)
        updateText(text: String(distance), atPosition: end)
        //print(abs(distance))
        
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0) // depth of 3D text
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode.geometry = textGeometry
        textNode.position = SCNVector3(position.x, position.y, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01) // reduce the size by 1% of the original figure
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
  
}
