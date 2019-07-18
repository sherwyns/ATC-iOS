//
//  ATCLocation.swift
//  ATC
//
//  Created by DHANDAPANI R on 13/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.


import Foundation
import CoreLocation

class ATCLocation: NSObject, CLLocationManagerDelegate {
    
    static let shared = ATCLocation()
    
    let locationManager = CLLocationManager()
    
    var delegate: LocationUpdate?
    
    private override init(){
        super.init()
        locationManager.delegate = self
    }
    
    func requestOneTimeLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //print("Found user's location: \(location)")
            delegate?.latestCoordinate(location)
            locationManager.stopUpdatingLocation()
            delegate = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Failed to find user's location: \(error.localizedDescription)")
        delegate?.message(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        delegate?.notifyDidChangeLocationAuthorization()
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .restricted, .denied, .notDetermined:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            requestOneTimeLocation()
            break
        }
    }
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .restricted, .denied, .notDetermined:
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.requestWhenInUseAuthorization()
                }
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                break
            }
        } else {
            
        }
    }
}

protocol LocationUpdate {
    func latestCoordinate(_ location: CLLocation)
    func message(_ string: String)
    func notifyDidChangeLocationAuthorization()
}
