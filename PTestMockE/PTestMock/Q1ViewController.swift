//
//  Q1ViewController.swift
//  PTestMock
//
//  Created by Alex Ooi on 5/6/17.
//  Copyright © 2017 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Q1ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sizeSegment: UISegmentedControl!
    @IBOutlet weak var distanceLabel: UILabel!

    var lm : CLLocationManager?
    
    var estateList : [Estate] = []
    
    var cl : CLLocation?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        lm = CLLocationManager()
        
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        
        lm?.distanceFilter = 5
        
        // Do any additional setup after loading the view.
        lm?.delegate = self
        let ios8 = lm?.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))
        if (ios8!) {
            lm?.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.global(qos: .background).async {
            HTTP.postJSON(url: "http://crowd.sit.nyp.edu.sg/itp312_2017s1/estate/list", json: JSON.init([]), onComplete: {
                json, response, error in
                
                if json == nil
                {
                    return
                }
                
                print(json!.count)
                
                for (_, value) in json! {
                    let e = Estate(
                        name: value["name"].string!,
                        population: value["pop"].int!,
                        latitude: value["latitude"].double!,
                        longitude: value["longitude"].double!)
                    self.estateList.append(e)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.showMapPins()
                }
            })
        }
        
        lm?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        cl = locations.last!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.estateList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath)
        
        var largeColor: UIColor?
        var smallColor: UIColor?
        
        if sizeSegment.selectedSegmentIndex == 0 {
            largeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            smallColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        else if sizeSegment.selectedSegmentIndex == 1 {
            largeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            smallColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        else
        {
            largeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            smallColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        }
        
        if estateList[indexPath.row].population >= 100000
        {
            cell.textLabel?.textColor = largeColor
            cell.detailTextLabel?.textColor = largeColor
        }
        else
        {
            cell.textLabel?.textColor = smallColor
            cell.detailTextLabel?.textColor = smallColor
        }
        cell.imageView?.image = UIImage(named: "house.jpg")
        cell.textLabel?.text = estateList[indexPath.row].name
        cell.detailTextLabel?.text = "Population: \(estateList[indexPath.row].population)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coordinate = CLLocation(latitude: estateList[indexPath.row].latitude, longitude: estateList[indexPath.row].longitude)
        
        if let distanceInMeters = cl?.distance(from: coordinate) {
            self.distanceLabel.text = String(format: "Distance: %.3f km", Double(distanceInMeters) / 1000)
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        tableView.reloadData()
    }
    
    func showMapPins() {
        for i in 0 ..< estateList.count
        {
            let dropPin = MapAnnotation(
                coordinate: CLLocationCoordinate2DMake(estateList[i].latitude, estateList[i].longitude),
                                        title: estateList[i].name,
                                        subtitle: "Population: \(estateList[i].population)")
            self.mapView.addAnnotation(dropPin)
        }
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
