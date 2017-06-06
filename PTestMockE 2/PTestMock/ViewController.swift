//
//  ViewController.swift
//  PTestMock
//
//  Created by Alex Ooi on 5/6/17.
//  Copyright © 2017 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    // Outlets
    @IBOutlet weak var sizeSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Location Manager optional
    var lm : CLLocationManager?
    
    // Current location optional
    var cl : CLLocation?
    
    // Estate array to store list of estates
    var estates : [Estate] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize location manager
        lm = CLLocationManager()
        
        // Set location manager delegate to ViewController
        lm?.delegate = self
        
        // Set distance filter to 5m
        lm?.distanceFilter = 5
        
        // Request authorization from user
        let ios8 = lm?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))
        if (ios8!) {
            lm?.requestAlwaysAuthorization()
        }
        
        if CLLocationManager.headingAvailable()
        {
            lm?.headingFilter = 5
            
            lm?.startUpdatingHeading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set tableView delegate and dataSource
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.mapView.delegate = self
        
        // Do any additional setup after loading the view.
        // Not necessary, to add HTTP runs in the background
        
        // Set background to postJSON to retrieve data
        HTTP.postJSON(
            url: "http://crowd.sit.nyp.edu.sg/itp312_2017s1/estate/list", // Set URL to post JSON to
            json: JSON.init([]), // Initialize empty JSON array
            onComplete: { // Closure on complete
            json, response, error in
            // postJSON responses
                
            if json == nil
            // Check for nil reply for JSON
            {
                return
            }
            
            for i in 0 ..< json!.count
            // Loop through JSON
            {
                // Add Estate object to estate list
                self.estates.append(
                    Estate(
                        name: json![i]["name"].string!,
                        population: json![i]["pop"].int!,
                        latitude: json![i]["latitude"].double!,
                        longitude: json![i]["longitude"].double!)
                )
            }
            
            DispatchQueue.main.async {
                // On completion of post, reload Data and showMapPins
                self.tableView.reloadData()
                self.showMapPins()
            }
        })
        
        // Start updating location for location manager
        lm?.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Not necessary
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath)
        
        let e = estates[indexPath.row]
        
        cell.imageView?.image = #imageLiteral(resourceName: "house")
        cell.textLabel?.text = e.name
        cell.detailTextLabel?.text = "Population: \(e.population)"
        
        cell.imageView?.alpha = 1.0
        cell.textLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        if (e.population >= 100000 && sizeSegment.selectedSegmentIndex == 1)
        {
            cell.imageView?.alpha = 0.3
            cell.textLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            cell.detailTextLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        }
        else if (e.population <= 100000 && sizeSegment.selectedSegmentIndex == 2)
        {
            cell.imageView?.alpha = 0.3
            cell.textLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            cell.detailTextLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let e = estates[indexPath.row]
        
        if let distanceBetween = cl?.distance(from: CLLocation(latitude: e.latitude, longitude: e.longitude)) {
            self.distanceLabel.text = String(format: "Distance: %.3f km", Double(distanceBetween) / 1000)
        }
    }
    
    // Implement this function in order to override the look at
    // feel of your callout
    //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            
        if annotation is MapAnnotation
        {
            // Pins can be reused just like table view cells as
            // they move in and out of the map
            var pinView = mapView.dequeueReusableAnnotationView(
                withIdentifier: "Annotation") as? MKPinAnnotationView
            if pinView == nil {
                // Creates a new bluish MKPinAnnotationView using the
                // same reuse ID as above.
                //
                pinView = MKPinAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: "Annotation")
                pinView?.pinTintColor = UIColor(
                    red: 0.1, green: 0.3, blue: 1, alpha: 0.7)
                pinView?.canShowCallout = true
                pinView?.animatesDrop = true
                //            // Show an image on the left side of the call out
                //            //
                //            let imageView = UIImageView(
                //                image: UIImage(named: "MapCallout"))
                //            imageView.frame = CGRect(
                //                x: 0,
                //                y: 0,
                //                width: 60,
                //                height: 60)
                //            imageView.contentMode = .scaleAspectFill
                //            pinView?.leftCalloutAccessoryView = imageView
                //            // Show a button on the right side of the call out 
                //            //
                //            let button = UIButton(type: .infoDark)
                //            pinView?.rightCalloutAccessoryView = button
            }
            
            return pinView
        }
        return nil
    }
    
    func showMapPins()
    {
        for i in 0 ..< estates.count
        {
            let coord = CLLocationCoordinate2D(latitude: estates[i].latitude, longitude: estates[i].longitude)
            let dropPin = MapAnnotation(coordinate: coord,
                                        title: estates[i].name,
                                        subtitle: "Population: \(estates[i].population)")
            self.mapView.addAnnotation(dropPin)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cl = locations.last
        
        var span = MKCoordinateSpan()
        span.longitudeDelta = 0.02
        span.latitudeDelta = 0.02
        
        var location = CLLocationCoordinate2D()
        location.latitude = (locations.last?.coordinate.latitude)!
        location.longitude = (locations.last?.coordinate.longitude)!
        
        var region = MKCoordinateRegion()
        region.span = span
        region.center = location
        
        mapView.setRegion(region, animated: true)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
