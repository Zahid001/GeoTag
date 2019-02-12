//
//  MapViewController.swift
//  GeoTag
//
//  Created by Md Zahidul Islam Mazumder on 6/2/19.
//  Copyright © 2019 Md Zahidul islam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,UISearchBarDelegate {

    
    var annotationLocations = [
        ["title" : "9/A, Ibn Sina trust building, Dhanmondi","lattitude" : 23.7451636, "longitude" : 90.370074 ],
        ["title" : "Nilu Squire, Sat Masjid Road, Dhanmondi R/A","lattitude" : 23.7418789, "longitude" : 90.3717531 ]
    
    ]
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let zooming: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        //mapView.showsUserLocation = true
        createMultipleAnnotations(locations: annotationLocations)
        //showUserZooming()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkPermission()
        }
        else{
            //alert
        }
    }
    
    func checkPermission()  {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            showUserZooming()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        
        case .restricted:
            break
        case .authorizedAlways:
            break
            
        }
    }
    
    func showUserZooming()  {
        if let location = locationManager.location?.coordinate {
            let regeion = MKCoordinateRegion.init(center: location, latitudinalMeters: zooming, longitudinalMeters: zooming)
            mapView.setRegion(regeion, animated: true)
        }
    }
    
    func createMultipleAnnotations(locations:[[String:Any]])  {
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location["title"] as? String
            annotation.coordinate = CLLocationCoordinate2D(latitude: location["lattitude"] as! CLLocationDegrees,  longitude: location["longitude"] as! CLLocationDegrees)
            mapView.addAnnotation(annotation)
            
            let coordinate = CLLocationCoordinate2DMake(location["lattitude"] as! CLLocationDegrees, location["longitude"] as! CLLocationDegrees)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let activityIndicatior = UIActivityIndicatorView()
        activityIndicatior.style = UIActivityIndicatorView.Style.gray
        activityIndicatior.center = self.view.center
        activityIndicatior.hidesWhenStopped = true
        activityIndicatior.startAnimating()
        
        self.view.addSubview(activityIndicatior)
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start {
            (response,error) in
            
            activityIndicatior.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil{
                print("Error")
            }
            else{
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                let lattitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2D(latitude: lattitude!, longitude: longitude!)
                self.mapView.addAnnotation(annotation)
                
                let coordinate = CLLocationCoordinate2DMake(lattitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                
            }
            
        }
        
    }
    
    

}

extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: zooming, longitudinalMeters: zooming)
        mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkPermission()
    }
}
