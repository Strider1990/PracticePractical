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

    @IBOutlet weak var sizeSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var lm : CLLocationManager?
    
    var cl : CLLocation?
    
    var estates : [Estate] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        lm = CLLocationManager()
        
        lm?.delegate = self
        
        lm?.distanceFilter = 5
        
        let ios8 = lm?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))
        if (ios8!) {
            lm?.requestAlwaysAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        DispatchQueue.global(qos: .background).async
        {
            HTTP.postJSON(url: "http://crowd.sit.nyp.edu.sg/itp312_2017s1/estate/list", json: JSON.init([]), onComplete: {
                json, response, error in
                
                if json == nil
                {
                    return
                }
                
                for i in 0 ..< json!.count
                {
                    self.estates.append(
                        Estate(
                            name: json![i]["name"].string!,
                            population: json![i]["pop"].int!,
                            latitude: json![i]["latitude"].double!,
                            longitude: json![i]["longitude"].double!)
                    )
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.showMapPins()
                }
            })
        }
        
        lm?.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath)
        
        let e = estates[indexPath.row]
        
        cell.imageView?.image = UIImage(named: "house.jpg")
        cell.textLabel?.text = e.name
        cell.detailTextLabel?.text = "Population: \(e.population)"
        
        cell.textLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        if (e.population >= 100000 && sizeSegment.selectedSegmentIndex == 1)
        {
            cell.textLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            cell.detailTextLabel?.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        }
        else if (e.population <= 100000 && sizeSegment.selectedSegmentIndex == 2)
        {
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
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
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
