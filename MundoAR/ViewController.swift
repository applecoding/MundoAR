//
//  ViewController.swift
//  MundoAR
//
//  Created by Julio César Fernández Muñoz on 31/1/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        drawEarth()
    }
    
    func drawEarth() {
        guard let diffuse = UIImage(named: "art.scnassets/earth_diffuse_4k.jpg"),
              let specular = UIImage(named: "art.scnassets/earth_specular_1k.jpg"),
              let lights = UIImage(named: "art.scnassets/earth_lights_4k.jpg"),
              let normal = UIImage(named: "art.scnassets/earth_normal_4k.jpg"),
              let nubes = UIImage(named: "art.scnassets/clouds_transparent_2K.jpg") else {
            return
        }
        
        let earth = SCNSphere(radius: 0.3)
        let earthNode = SCNNode(geometry: earth)
        earthNode.name = "earth"
        
        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = diffuse
        earthMaterial.specular.contents = specular
        earthMaterial.normal.contents = normal
        earthMaterial.emission.contents = lights
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        earthMaterial.shininess = 0.5
        
        earth.firstMaterial = earthMaterial
        
        let clouds = SCNSphere(radius: 0.3075)
        clouds.segmentCount = 144
        
        let cloudsMaterial = SCNMaterial()
        cloudsMaterial.diffuse.contents = UIColor.white
        cloudsMaterial.locksAmbientWithDiffuse = true
        cloudsMaterial.transparent.contents = nubes
        cloudsMaterial.transparencyMode = .rgbZero
        cloudsMaterial.writesToDepthBuffer = false
        
        if let shaderURL = Bundle.main.url(forResource: "AtmosphereHalo", withExtension: "glsl"),
           let content = try? Data(contentsOf: shaderURL), let string = String(data: content, encoding: .utf8) {
            cloudsMaterial.shaderModifiers = [.fragment: string]
        }
        
        clouds.firstMaterial = cloudsMaterial
        
        let cloudNode = SCNNode(geometry: clouds)
        cloudNode.name = "nubes"
        earthNode.addChildNode(cloudNode)

        let axisNode = SCNNode()
        sceneView.scene.rootNode.addChildNode(axisNode)
        axisNode.addChildNode(earthNode)
        axisNode.rotation = SCNVector4(1, 0, 0, Double.pi/6.0)
        
        earthNode.position = SCNVector3(0, -0.5, -1)
        
        earthNode.rotation = SCNVector4(0, 1, 0, 0)
        cloudNode.rotation = SCNVector4(0, 1, 0, 0)
        
        let sun = SCNLight()
        sun.type = .spot
        sun.castsShadow = true
        sun.shadowRadius = 0.3
        sun.shadowColor = UIColor(white: 0.0, alpha: 0.75)
        sun.zNear = 1.0
        sun.zFar = 4.0
        
        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.name = "sol"
        sunNode.position = SCNVector3(-15, 0, 12)
        sunNode.constraints = [SCNLookAtConstraint(target: earthNode)]
        sceneView.scene.rootNode.addChildNode(sunNode)
        
        let earthRotate = CABasicAnimation(keyPath: "rotation.w")
        earthRotate.byValue = CGFloat.pi * 2.0
        earthRotate.duration = 50
        earthRotate.timingFunction = CAMediaTimingFunction(name: .linear)
        earthRotate.repeatCount = .infinity
        earthNode.addAnimation(earthRotate, forKey: "Rotar tierra")

        let cloudRotate = CABasicAnimation(keyPath: "rotation.w")
        cloudRotate.byValue = -CGFloat.pi * 2.0
        cloudRotate.duration = 150
        cloudRotate.timingFunction = CAMediaTimingFunction(name: .linear)
        cloudRotate.repeatCount = .infinity
        cloudNode.addAnimation(cloudRotate, forKey: "Rotar nubes")
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let sol = sceneView.scene.rootNode.childNode(withName: "sol", recursively: false),
              let intensidad = session.currentFrame?.lightEstimate?.ambientIntensity,
              let temperatura = session.currentFrame?.lightEstimate?.ambientColorTemperature,
              let luz = sol.light else {
            return
        }
        if luz.intensity != intensidad {
            sol.light?.intensity = intensidad
            sol.light?.temperature = temperatura
        }
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
}
