//
//  ViewController.swift
//  LocationLoktra
//
//  Created by Saurabh Yadav on 08/04/17.
//  Copyright © 2017 Saurabh Yadav. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var totalShiftTimeView: UIView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    var shouldUpdateStartCounter = 0
    
    @IBOutlet weak var customLocationSlider: CustomSlider!
    @IBOutlet weak var slideLeftRightLabel: UILabel!
    
    @IBOutlet weak var mapviewLocation: MKMapView!
    var startLocation : CLLocation?
    var endLocation : CLLocation?
    var myRoute : MKRoute!

//        didSet{
//            startLocation = nil
//        }
//    }
    let locationManager = CLLocationManager()
    
    var beginTime : TimerCalculator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomSlider()
        setupTotalTimeView()
        self.mapviewLocation.delegate = self
    }
    
    func setupCustomSlider(){
        self.customLocationSlider.setThumbImage(UIImage
            .init(named: "right"), for: .normal)
        self.customLocationSlider.minimumTrackTintColor = UIColor.red
        self.customLocationSlider.maximumTrackTintColor = UIColor.green
        self.customLocationSlider.isContinuous = false
    }
    
    func checkLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
                if self.shouldUpdateStartCounter == 0{
                    locationManager.startUpdatingLocation()
                }
            }else{
                self.showEnableLocationAlert()
            }
        }
        else{
            self.showEnableLocationAlert()
        }
    }

    func setupTotalTimeView(){
        self.totalShiftTimeView.addShadowView()
        self.totalShiftTimeView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            startLocation = nil
            locationManager.requestLocation()
        }else{
            self.checkLocation()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
    
        if (self.customLocationSlider.isTracking) {
//            print("Slider Touched")
        } else {
            print("Slider Released")
            if self.customLocationSlider.value < 0.5 {
                self.updateSlideRightValues()
            }else{
                self.updateSlideLeftValues()
            }
        }
    }
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        let location = manager.location
        if shouldUpdateStartCounter == 0 {
            if let pointsArray = self.mapviewLocation.overlays as? NSArray{
                self.mapviewLocation.removeOverlays(pointsArray as! [MKOverlay])
            }
            shouldUpdateStartCounter += 1
            startLocation = location
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingLocation()
        } else if shouldUpdateStartCounter == -1 {
            endLocation = location
            shouldUpdateStartCounter -= 1
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingLocation()
            
            let annotation = MKPointAnnotation()
            annotation.title = "Previous Location"
            annotation.coordinate = CLLocationCoordinate2D(latitude: (startLocation?.coordinate.latitude)!, longitude: (startLocation?.coordinate.longitude)!)
            self.mapviewLocation.addAnnotation(annotation)
            
        self.showRouteOnMap()
        }
        print(startLocation?.coordinate ?? "start 0", endLocation?.coordinate ?? "end 0")
        mapviewLocation.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                        self.showEnableLocationAlert()
                }
            }
        }
    }
    
    func showEnableLocationAlert(){
        self.startLocation = nil
        self.shouldUpdateStartCounter = 0
        self.customLocationSlider.setValue(0, animated: true)
        self.slideLeftRightLabel.text = "Slide Right To Start Shift"
        self.customLocationSlider.setThumbImage(UIImage
            .init(named: "right"), for: .normal)

        let alert = UIAlertController(title: "Alert", message: "Please enable location service in the Settigs app under Privacy, Location Services. To get the location.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            self.checkLocation()
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showRouteOnMap() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: (startLocation?.coordinate)!, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: (endLocation?.coordinate)!, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response : MKDirectionsResponse?, error : Error?) in
            if error == nil {
                self.myRoute = (response?.routes[0])! as MKRoute
                
                self.mapviewLocation.add(self.myRoute.polyline)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor = UIColor.red
        myLineRenderer.lineWidth = 3
        return myLineRenderer

    }
    
    func updateSlideRightValues(){
        self.customLocationSlider.setThumbImage(UIImage
            .init(named: "right"), for: .normal)
        self.slideLeftRightLabel.text = "Slide Right To Start Shift"
        self.customLocationSlider.setValue(0, animated: true)
        
        guard let diffTime = self.beginTime?.stop() else {
            return
        }
        let hours = diffTime.truncatingRemainder(dividingBy: 3600.0)/3600
        let minutes = diffTime.truncatingRemainder(dividingBy: 3600.0)/60
        print(diffTime, hours , minutes)
        self.totalShiftTimeView.isHidden = false
        self.totalTimeLabel.text = String.init(format: "%.0f h %.0f m", hours, minutes)
        shouldUpdateStartCounter = -1
        locationManager.startUpdatingLocation()
        beginTime = nil
    }
    
    func updateSlideLeftValues(){
        self.customLocationSlider.setThumbImage(UIImage
            .init(named: "left"), for: .normal)
        if beginTime == nil {
            beginTime = TimerCalculator.init()
            self.totalShiftTimeView.isHidden = true
        }
        self.slideLeftRightLabel.text = "Slide Left To End Shift"
        self.customLocationSlider.setValue(1, animated: true)
        self.shouldUpdateStartCounter = 0
        self.checkLocation()
    }
}
