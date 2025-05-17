//
//  UserDefaultsService.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-17.
//


import MapKit

protocol StorageServiceProtocol {
    func saveCircle(circle: MKCircle)
    func catchCircle()->MKCircle?
    func removeCircle()
    func catchButtonVisibilityState() -> Bool?
    func saveButtonVisibilityState(visibilityState:Bool)
}

class StorageService:StorageServiceProtocol {
    
    func catchButtonVisibilityState() -> Bool?{
        if UserDefaults.standard.object(forKey: "visibilityState") != nil {
              return UserDefaults.standard.bool(forKey: "visibilityState")
          }
          return nil
    }
    
    func saveButtonVisibilityState(visibilityState:Bool){
        UserDefaults.standard.set(visibilityState, forKey: "visibilityState")
    }
    
    func saveCircle(circle: MKCircle) {
        let circleInfo = [
            "lat":circle.coordinate.latitude,
            "lon":circle.coordinate.longitude,
            "radius":circle.radius
        ]
        UserDefaults.standard.set(circleInfo, forKey: "circleInfo")
    }
    
    func catchCircle()->MKCircle?{
        if let circleInfo = UserDefaults.standard.dictionary(forKey: "circleInfo") as? [String: CLLocationDegrees],
              let lat = circleInfo["lat"],
              let lon = circleInfo["lon"],
              let radius = circleInfo["radius"] {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return MKCircle(center: coordinate, radius: radius)
        }
        return nil
    }
    func removeCircle(){
        UserDefaults.standard.removeObject(forKey: "circleInfo")
    }
}
