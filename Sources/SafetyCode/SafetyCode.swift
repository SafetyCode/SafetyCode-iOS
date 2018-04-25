import CoreLocation
import Foundation
import UIKit


public class SafetyCode: NSObject, CLLocationManagerDelegate {

    let updateInterval = 5.0 // how often to run speed check
    let averageCount = 8 // number of average speed values to use in calculation
    var asked = false // has showed alert

    let speedLimit = 20.0 // speed limit
    var warned = false // time for last speed check
    var lastCheck   = 0.0 // time for last speed check
    var lastCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) // coordinate for last speed check
    var currentCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) // current coordinate

    var alertOptions: [String: String] = [
        "title": "Oops! You're not driving are you?",
        "message": "This app is speed lockded for your own safety.",
        "actionTitle": "I'm not the driver"
    ]  // options for alert


    var currentSpeed = 0.0 // current calculated speed
    var averageSpeed = 0.0 // average speed

    var speeds: [Double] = [] // average speeds
    let locationManager = CLLocationManager()

    public init(options:[String: String] = [:]) {
        if (!options.isEmpty) {
            alertOptions = alertOptions.merging(options) { (_, new) in new }
        }
        super.init()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {

            switch(CLLocationManager.authorizationStatus()) {
            //check if services disallowed for this app particularly
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
//                let accessAlert = UIAlertController(title: "Location Services Disabled", message: "You need to enable location services in settings.", preferredStyle: UIAlertControllerStyle.alert)
//
//                accessAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
//                }))
//
//                UIApplication.shared.keyWindow?.rootViewController?.present(accessAlert, animated: true, completion: nil)

            //check if services are allowed for this app
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access! We're good to go!")
            //check if we need to ask for access
            default:
                print("asking for access...")
                locationManager.requestWhenInUseAuthorization()
            }
            //location services are disabled on the device entirely!
        } else {
            print("Location services are not enabled")

        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.handlePosition), userInfo: nil, repeats: true)

    }


    func showAlert() {

        if (self.warned) {
            return
        }
        self.warned = true
        let alert = UIAlertController(title: alertOptions["title"], message: alertOptions["message"], preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: alertOptions["actionTitle"], style: .default, handler: { action in


            switch action.style{
            case .default:
                print("default")

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

            }}))
//        self.vc.present(alert, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }


    @objc func handlePosition() {
        let coordinate:CLLocationCoordinate2D = currentCoordinate
        var seconds = 0.0
        var hours = 0.0

        let currentTime =  NSDate().timeIntervalSince1970 * 1000
//        print("CURRENT - lat " + String(coordinate.latitude) + " / lng " + String(coordinate.longitude))

        if (lastCoordinate.latitude == coordinate.latitude && lastCoordinate.longitude == coordinate.longitude) {
            return
        }

        let distance  = self.distance(coordinate: coordinate)

        if (self.lastCheck == 0) {
            seconds = 0
        } else {
            seconds = (currentTime - self.lastCheck) / 1000
        }
        hours = seconds / (60*60)

        if (hours > 0 && distance > 0) {
            self.currentSpeed = floor(distance / hours)
        } else {
            self.currentSpeed = 0
        }
        // print("distance: " + String(distance) + " hours: " + String(hours) + " speed: " + String(self.currentSpeed))

        // even out for gps glitches
        if(self.speeds.count > 0 && self.currentSpeed > (self.speeds[self.speeds.count - 1] + 20)) {
           self.currentSpeed = self.speeds[self.speeds.count - 1] + 20
        }
        self.speeds.append(self.currentSpeed)

        // do we have enough values to estimate speed
        if(self.speeds.count >= self.averageCount) {
            let tmpSpeeds: ArraySlice<Double>
            tmpSpeeds = self.speeds.suffix(self.averageCount)

            var speedSum = 0.0
            for speed in tmpSpeeds {
                speedSum += speed
            }

            self.averageSpeed = speedSum / Double(tmpSpeeds.count)
            print("averageSpeed: " + String(self.averageSpeed))

            if (self.averageSpeed >= self.speedLimit && self.currentSpeed >= self.speedLimit && !self.warned) {
                self.showAlert()
                //manager.stopUpdatingLocation()
            }

//            if(self.averageSpeed <= 1.0) {
//                self.warned = false
//            }

        }
        self.lastCheck = currentTime
        self.lastCoordinate = coordinate

    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let userLocation:CLLocation = locations[0] as CLLocation
        currentCoordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
    }


    func distance(coordinate: CLLocationCoordinate2D)  -> Double {
        if (self.lastCoordinate.latitude == 0 || self.lastCoordinate.longitude == 0) {
            return 0
        }

        var radLat1 = 0.0
        var radLat2 = 0.0
        var theta = 0.0
        var radtheta = 0.0

        radLat1 = Double.pi * coordinate.latitude / 180
        radLat2 = Double.pi * lastCoordinate.latitude / 180
        theta = coordinate.longitude - lastCoordinate.longitude
        radtheta = Double.pi * theta / 180

        var dist = sin(radLat1) * sin(radLat2) + cos(radLat1) * cos(radLat2) * cos(radtheta)

        dist = acos(dist)
        dist = dist * 180 / Double.pi
        dist = dist * 60 * 1.1515

        // Calculates the distance into kilometers.
        dist = dist * 1.609344
        return dist
    }
}
