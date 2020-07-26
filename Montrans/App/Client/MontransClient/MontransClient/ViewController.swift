//
//  ViewController.swift
//  MontransClient
//
//  Created by  brazilec22 on 25.07.2020.
//  Copyright © 2020  brazilec22. All rights reserved.
//

import UIKit
import CoreTelephony
import CoreLocation

struct cellur {
    var name : String?
    var radio : String?
}

class cellurInformation : CTTelephonyNetworkInfo {
     func getCellularInfo() -> cellur {
        var structRadioCoverage = cellur()
        let celluraInfo = CTTelephonyNetworkInfo()
        let serviceCellularProvider = celluraInfo.serviceSubscriberCellularProviders
        let idCellularProvider = celluraInfo.dataServiceIdentifier
        let currentRadi = celluraInfo.serviceCurrentRadioAccessTechnology
        structRadioCoverage.name = serviceCellularProvider![idCellularProvider!]?.carrierName
        structRadioCoverage.radio = currentRadi![idCellularProvider!]
        return structRadioCoverage
    }
}
var timeCellular = Timer()

class ViewController: UIViewController {
    var currentCellular = cellurInformation()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.trackingTimer()
        self.initLocationManager()
        self.startLocation()
        // Do any additional setup after loading the view.
    }
    @objc  func TrackingMyCellular() {
        print(currentCellular.getCellularInfo())
    }
    func trackingTimer() {
        timeCellular.invalidate()
        timeCellular = Timer.scheduledTimer(timeInterval: 2,
                                            target: self,
                                            selector: #selector(self.TrackingMyCellular),
                                            userInfo: nil,
                                            repeats: true)
       }
}

extension ViewController : CLLocationManagerDelegate {
    // MARK 1
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    }
    // MARK 2
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            print("Warning: No last location found")
            return
        }
        print(lastLocation.timestamp)
        print(lastLocation.coordinate)
        print(currentCellular.getCellularInfo())
    }
    // MARK 3
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    // MARK 4
    func startLocation() {
        locationManager.startUpdatingLocation()
    }
    // MARK 5
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
}


