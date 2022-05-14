//
//  ViewController.swift
//  DeviceOrientationTest
//
//  Created by Fabian Kuschke on 14.05.22.
//

import UIKit
import CoreMotion
import ARKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    var sceneView: ARView!
    let motionManager = CMMotionManager()
    var switchViewToMap = false
    
    var actualViewText = ""
    
    let arConfig = ARWorldTrackingConfiguration()
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
                
        arConfig.isAutoFocusEnabled = true
        arConfig.isLightEstimationEnabled = true
        sceneView = ARView(frame: self.arView.frame)
        //sceneView.session.delegate = self
        self.arView.insertSubview(sceneView, at: 0)
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.1
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { deviceManager, error in
                guard let manager = deviceManager else {return}
                
                let angle = manager.attitude.pitch * 180 / Double.pi
                if angle < 35 {
                    if !self.switchViewToMap{
                        self.actualViewText = "MAP"
                        self.switchToMap()
                    }
                    self.switchViewToMap = true
                }else{
                    if self.switchViewToMap {
                        self.actualViewText = "AR"
                        self.switchToAR()
                    }
                    self.switchViewToMap = false
                }
                DispatchQueue.main.async{
                    self.testLabel.text = String(format: "\(self.actualViewText) %.2f ", angle)
                }
                
            }
        }else {
            print("Device motion not available")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deactivateAR()
    }
    
    //MARK: Activate AR
    private func activateAR(){
        //if let configuration = sceneView.session.configuration {
            sceneView.session.run(arConfig, options: [.resetTracking, .resetSceneReconstruction, .removeExistingAnchors])
        //}
    }
    
    //MARK: Deactivate AR
    private func deactivateAR(){
        if self.sceneView != nil {
            self.sceneView.session.pause()
            //self.sceneView.removeFromSuperview()
            //self.sceneView = ARView()
        }

    }
    
    //MARK: Switch To AR
    private func switchToAR(){
        DispatchQueue.main.async{
            self.activateAR()
            self.arView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.mapView.alpha = 0
                self.mapView.transform = self.mapView.transform.scaledBy(x: 1.1, y: 1.1)
                
                self.arView.alpha = 1
                self.arView.transform = self.arView.transform.scaledBy(x: 1.3, y: 1.3)
                
            }) { _ in
                self.mapView.isHidden = true
            }
            
        }
    }
    
    //MARK: Switch To Map
    private func switchToMap(){
        DispatchQueue.main.async{
            self.mapView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.arView.alpha = 0
                self.arView.transform = self.arView.transform.scaledBy(x: 1.1, y: 1.1)
                
                self.mapView.alpha = 1
                self.mapView.transform = self.mapView.transform.scaledBy(x: 1.3, y: 1.3)
            }) { _ in
                self.arView.isHidden = true
                self.deactivateAR()
            }
            
        }
    }
    
    
}

