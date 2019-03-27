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
import Cosmos
import Firebase


class MapViewController: UIViewController,UISearchBarDelegate,MKMapViewDelegate {

    var cosmosView = CosmosView()
    var annotationLocations =
        [["title" : "9/A, Ibn Sina trust building, Dhanmondi","lattitude" : 23.7451636, "longitude" : 90.370074 ],
        ["title" : "Nilu Squire, Sat Masjid Road, Dhanmondi R/A","lattitude" : 23.7418789, "longitude" : 90.3717531 ]
    
    ]
    
    
    
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var anotationTitle: UITextField!
    @IBOutlet weak var annotationDescription: UITextField!
    @IBOutlet weak var ratting: CosmosView!
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let zooming: Double = 1000
    
    
    
    @IBAction func cancelAnnotationInfo(_ sender: Any) {
        animateOut()
    }
    
    @IBAction func saveAnnotationInfo(_ sender: Any) {
        ratting.didTouchCosmos = {
            rating in
            print("gjhk" ,rating)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMultipleAnnotations(locations: annotationLocations)
        mapView.delegate = self
        popUpView.layer.cornerRadius = 5
        checkLocationServices()
        //mapView.showsUserLocation = true
        
        getAnnotaionDetails()
        
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        self.mapView.addGestureRecognizer(longPressRecognizer)
        
        print("hhhhh" , annotationLocations)
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
    
    
    
    
    @objc func longPress(_ longPressClicked:UILongPressGestureRecognizer)   {
        
        let annotationDB = Database.database().reference().child("AnnotationnDetail")
        var titl:String = ""
        var textField = UITextField()
        //var btn = UIButton()
        
        let location = longPressClicked.location(in: mapView)
        
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let alert = UIAlertController(title: "Add Location", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Add Place", style: .default) { (UIAlertAction) in



                titl = textField.text!
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate

                annotation.title = titl
                let annotationDictionary = [
                    
                    "title" : titl,
                    "lattitude" : coordinate.latitude,
                    "longitude" : coordinate.longitude,
                    "star" : 5.0
                
                    ] as [String : Any]
                
                annotationDB.childByAutoId().setValue(annotationDictionary){
                    (error,ref) in
                    
                    if error != nil {
                        print(error!)
                    } else {
                        print("details saved")
                    }
                }
                print(coordinate.latitude)

                self.annotationLocations.append(annotationDictionary)
                self.mapView.addAnnotation(annotation)



            }

            alert.addAction(action)

            alert.addTextField { (UITextField) in
                UITextField.placeholder = "Give location name"
                textField = UITextField

            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        alert.addAction(cancelAction)


            present(alert,animated: true)
            
        }
        
    func getAnnotaionDetails(){
        let annotationDB = Database.database().reference().child("AnnotationnDetails")
        annotationDB.observe(.childAdded) { (DataSnapshot) in
            let annotationValue = DataSnapshot.value as! Dictionary<String , Any>
            let title = annotationValue["title"]
            let lat = annotationValue["lattitude"]
            let lon = annotationValue["longitude"]
            print(lat!, lon!, title!)
            let dict = [
                "title" : title!,
                "lattitude" : lat!,
                "longitude" : lon!
            ] as [String : Any]
            self.annotationLocations.append(dict  )
            self.createMultipleAnnotations(locations: self.annotationLocations)
        }
    }
    

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        animateIn()
    }
    
    func animateIn() {
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            //self.visualEffectView.effect = self.effect
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
        
    }
    
    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpView.alpha = 0
            
            //self.visualEffectView.effect = nil
            
        }) { (success:Bool) in
            self.popUpView.removeFromSuperview()
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
