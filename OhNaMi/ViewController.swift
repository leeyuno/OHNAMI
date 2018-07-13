//
//  ViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 21/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var LocalButton: UIButton!
    @IBOutlet weak var LocalText: UILabel!
    
    var location: CLLocation? = nil
    var address: String!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewdidload")
        
    }
    
    @IBAction func LocalButton(_ sender: Any) {
        print("button tapped")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
            //latitude:위도, longitude:경도
            
            location = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
            
            convertToAddressWith(coordinate: location!)
        }
    }
    
    //위도 경도 주소로반환
    func convertToAddressWith(coordinate: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            

            // Street address
            let thoroughfare = placeMark.addressDictionary!["Thoroughfare"] as! String

            // City
            let city = placeMark.addressDictionary!["City"] as! String
            
            /*guard let placemark = placemarks?.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            let address = addrList.joined(separator: " ")
            print(address)
            
            print(addrList)*/
            
            self.locationManager.stopUpdatingLocation()
            
            self.address = thoroughfare + " " + city
            
            self.LocalText.text = self.address
            //print(self.address)

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

