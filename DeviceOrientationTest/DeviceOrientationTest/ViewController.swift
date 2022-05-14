//
//  ViewController.swift
//  DeviceOrientationTest
//
//  Created by Fabian Kuschke on 14.05.22.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    let motionManager = CMMotionManager()
    var switchViewToMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.1
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { deviceManager, error in
                guard let manager = deviceManager else {return}
                
                let angle = manager.attitude.pitch * 180 / Double.pi
                if angle < 35 {
                    if !self.switchViewToMap{
                        print("Map \(angle)")
                        self.switchToMap()
                    }
                    self.switchViewToMap = true
                }else{
                    if self.switchViewToMap {
                        print("AR \(angle)")
                        self.switchToAR()
                    }
                    self.switchViewToMap = false
                }
                DispatchQueue.main.async{
                    self.testLabel.text = "Angle: \(angle)"
                }
                
            }
        }else {
            print("Device motion unavailable")
        }
        
    }
    
    //MARK: Switch To AR
    private func switchToAR(){
        DispatchQueue.main.async{
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
            }
            
        }
    }
    
    
}

