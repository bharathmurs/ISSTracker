//
//  ISSTrackerViewController.swift
//  ISSTracker
//
//  Created by Bharath Urs on 8/22/15.
//  Copyright (c) 2015 Urs. All rights reserved.
//

import UIKit
import MapKit

class ISSTrackerViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let zoomLevelDistance: CLLocationDistance = 5000000
    let mapViewAnnotationIdentifier = "mapviewannotation"
    let service = ISSService()
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        let initialLocation = CLLocation(latitude: -8.851651956769725, longitude: -120.15492569005845)
        setMapWithLocation(initialLocation, annotationTitle: "ISS")
        
        fetchISSLocation()
        
    }

    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("fetchISSLocation"), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func fetchISSLocation() {
        service.fetchISSLocation { (location, annotationTitle) -> Void in
            self.setMapWithLocation(location, annotationTitle: annotationTitle)
        }
    }
    
    @IBAction func refreshISSLocation(sender: UIBarButtonItem) {
        fetchISSLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setMapWithLocation(location: CLLocation, annotationTitle: String) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, zoomLevelDistance, zoomLevelDistance)
        mapView.setRegion(coordinateRegion, animated: true)
        
        var title = annotationTitle
        if annotationTitle.isEmpty {
            title = "Oops, am in middle of nowhere.!"
        }
        
        let annotation = Spaceship(title: title, coordinate: location.coordinate)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func autoUpdateToggle(sender: UISwitch) {
        if sender.on {
            self.startTimer()
        }
        else {
            self.stopTimer()
        }
    }
}

extension ISSTrackerViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(mapViewAnnotationIdentifier) {
            return annotationView
        }
        else {
           let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: mapViewAnnotationIdentifier)
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "spaceship.png")
            return annotationView
        }
    }
}

class Spaceship: NSObject, MKAnnotation {
    let title: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
}
