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
import MapKit
import CoreLocation


//MARK: Enable this if you don't want AR and Map
let showARandMapViews = false

class ViewController: UIViewController {
    
    //MARK: Vars
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    var sceneView: ARView!
    let motionManager = CMMotionManager() //device Rotation
    var theMapView: MKMapView! //Map View
    let locationManager = CLLocationManager() //Location
    var currentLocation : CLLocation?   //Location
    
    var switchViewToMap = false
    var actualViewText = ""
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if showARandMapViews {
            sceneView = ARView(frame: CGRect(x: 0, y: 0, width: self.arView.frame.width, height: self.arView.frame.height))
            self.arView.addSubview(sceneView)
            
            theMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height))
            theMapView.mapType = MKMapType.standard
            theMapView.isZoomEnabled = true
            theMapView.isScrollEnabled = true
            theMapView.center = view.center
            
            theMapView.delegate = self
            theMapView.showsCompass = true
            theMapView.showsScale = true
            theMapView.showsTraffic = true
            
            mapView.addSubview(theMapView)
            
            locationManager.delegate = self
            
            getCurrentLocation()
        }
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.1
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { deviceManager, error in
                guard let manager = deviceManager else {return}
                
                let angle = manager.attitude.pitch * 180 / Double.pi
                if angle < 35 {
                    if !self.switchViewToMap{
                        self.actualViewText = "MAP"
                        self.testLabel.textColor = .black
                        self.testLabel.backgroundColor = .systemGreen
                        self.switchToMapAnim()
                    }
                    self.switchViewToMap = true
                }else{
                    if self.switchViewToMap {
                        self.actualViewText = "AR"
                        self.testLabel.textColor = .white
                        self.testLabel.backgroundColor = .systemBlue
                        self.switchToARAnim()
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
    
    private func getCurrentLocation(){
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() && locationManager.authorizationStatus == .denied {
            print("Access denied. restart and authorize App")
            return
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: Activate MAP
    private func activateMap(){
        if let location = currentLocation{
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            self.theMapView.showAnnotations([annotation], animated: true)
            self.theMapView.selectAnnotation(annotation, animated: true)
            self.theMapView.showAnnotations([annotation], animated: true)
            self.theMapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //MARK: Activate AR
    private func activateAR(){
        if let configuration = sceneView.session.configuration {
            sceneView.session.run(configuration, options: [.resetTracking, .resetSceneReconstruction, .removeExistingAnchors])
        }
    }
    
    //MARK: Deactivate AR
    private func deactivateAR(){
        if self.sceneView != nil {
            self.sceneView.session.pause()
        }
    }
    
    //MARK: Switch To AR
    private func switchToARAnim(){
        DispatchQueue.main.async{
            if showARandMapViews {
                self.activateAR()
            }
            self.arView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.mapView.alpha = 0
                self.arView.alpha = 1
                
            }) { _ in
                self.mapView.isHidden = true
            }
        }
    }
    
    //MARK: Switch To Map
    private func switchToMapAnim(){
        DispatchQueue.main.async{
            self.mapView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.arView.alpha = 0
                self.mapView.alpha = 1
            }) { _ in
                self.arView.isHidden = true
                self.deactivateAR()
            }
        }
    }
    
    
}

extension ViewController: MKMapViewDelegate {
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else { return }
        currentLocation = location
        self.locationManager.stopUpdatingLocation()
        activateMap()
    }
}


