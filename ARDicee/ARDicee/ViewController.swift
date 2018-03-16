//
//  ViewController.swift
//  ARDicee
//
//  Created by Wang, Zewen on 2018-03-14.
//  Copyright © 2018 Wang, Zewen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //Create a cube
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        cube.materials = [material]
//        //nodes are points in 3D, position...
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = cube
//        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true // add shadow and lights, looks more 3D

        // Create a sphere
//        let sphere = SCNSphere(radius: 0.1)
//        let material = SCNMaterial()
////        material.diffuse.contents = UIImage(#imageLiteral(resourceName: "moon.jpg"))
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//        //nodes are points in 3D, position...
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true // add shadow and lights, looks more 3D
        
        
        
        
        sceneView.autoenablesDefaultLighting = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // setting this will trigger the function of didAdd
        print("World Tracking is supported \(ARWorldTrackingConfiguration.isSupported)")
        print("AR Configuration is supported \(ARConfiguration.isSupported)")
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touches are from users, use ARKit to convert to real world location
        // could enable multiple touches// isMultipleTouchEnabled
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            // convert 2d to 3d
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
//            if !results.isEmpty{
//                print("touched the plane")
//            }else{
//                print("touched somewhere else")
//            }
            
            if let hitResult = results.first{
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                    // Name is the one under diceCollada - scene graph - Dice
                    // recursively : allow searching the tree including all the subtrees
                    //diceNode.position = SCNVector3(0, 0, -0.1)
                    diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, hitResult.worldTransform.columns.3.z)
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode) // if add ! after diceNode, app may crash when diceNode is nil, be safe, add if let...
                    roll(dice: diceNode)
                    
                }
            }
        }
    }
    
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice : SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        //Y does not change. The height is always that. X and Y is the facet we are facing
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX) * 5, y: 0, z: CGFloat(randomZ) * 5, duration: 0.5))
        //multiply 5 can make the dice as any degree, from visualization part, it will look like rolling faster
    }

    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }// shake the phone to roll the dice
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // A delegate function
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //cooperate with anchor to place or visualize things, anchor - real world position
        if anchor is ARPlaneAnchor{ // to check whether added thing is plane anchor
            //print("Plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            //现在这个是立起来的平面，需要clockwise旋转90度之后才能变成horizontal的
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            // add the material to the planeNode, and add the planeNode into node, we will see the grid in the view
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            node.addChildNode(planeNode)
            
        }else{
            return
        }
    }
    
}
