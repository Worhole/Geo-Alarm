//
//  UserDefaultsService.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-17.
//

import MapKit

enum StorageKeys: String{
    case visibilityState = "visibilityState"
    case circleInfo = "circleInfo"
    case requests = "requests"
}

protocol StorageServiceProtocol {
    func saveCircle(circle: MKCircle)
    func catchCircle()->MKCircle?
    func removeCircle()
    func catchButtonVisibilityState() -> Bool?
    func saveButtonVisibilityState(visibilityState:Bool)
    func addSearchHistoryItem(_:String)
    func loadSearchHistory()->[String]
    func removeSearchHistoryItem(at index:Int)
}

class StorageService:StorageServiceProtocol {
    
    func catchButtonVisibilityState() -> Bool?{
        if UserDefaults.standard.object(forKey: StorageKeys.visibilityState.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.visibilityState.rawValue)
        }
        return nil
    }
    
    func saveButtonVisibilityState(visibilityState:Bool){
        UserDefaults.standard.set(visibilityState, forKey: StorageKeys.visibilityState.rawValue)
    }
    
    func saveCircle(circle: MKCircle) {
        let circleInfo = [
            "lat":circle.coordinate.latitude,
            "lon":circle.coordinate.longitude,
            "radius":circle.radius
        ]
        UserDefaults.standard.set(circleInfo, forKey: StorageKeys.circleInfo.rawValue)
    }
    
    func catchCircle()->MKCircle?{
        if let circleInfo = UserDefaults.standard.dictionary(forKey: StorageKeys.circleInfo.rawValue) as? [String: CLLocationDegrees],
           let lat = circleInfo["lat"],
           let lon = circleInfo["lon"],
           let radius = circleInfo["radius"] {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return MKCircle(center: coordinate, radius: radius)
        }
        return nil
    }
    
    func removeCircle(){
        UserDefaults.standard.removeObject(forKey: StorageKeys.circleInfo.rawValue)
    }
    
    func addSearchHistoryItem(_ item:String){
        var requests = UserDefaults.standard.stringArray(forKey: StorageKeys.requests.rawValue) ?? []
        requests.removeAll { $0 == item}
        requests.insert(item, at: 0)
        if requests.count > 15 {
            requests.removeLast()
        }
        UserDefaults.standard.set(requests, forKey: StorageKeys.requests.rawValue)
    }
    
    func loadSearchHistory()->[String]{
        return UserDefaults.standard.stringArray(forKey: StorageKeys.requests.rawValue) ?? []
    }
    
    func removeSearchHistoryItem(at index:Int){
        var requests = UserDefaults.standard.stringArray(forKey: StorageKeys.requests.rawValue)
        requests?.remove(at: index)
        UserDefaults.standard.set(requests, forKey: StorageKeys.requests.rawValue)
    }
}
