


import MapKit

protocol LocationServiceDelegate:AnyObject {
    func didEnterRegion(_ region: CLRegion)
    func didDetermineState(_ state: CLRegionState, for region: CLRegion)
}

protocol LocationServiceProtocol:AnyObject{
    var delegate: LocationServiceDelegate? { get set }
    
    func isAlwaysAuthorization()->Bool
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func startMonitoring(coordinate: CLLocationCoordinate2D)
    func checkState(coordinate:CLLocationCoordinate2D)
    func stopMonitoring()
}

class LocationService:NSObject, LocationServiceProtocol {
  
    private let locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoring(coordinate: CLLocationCoordinate2D) {
        stopMonitoring()
    
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
        
    }
    
    func checkState(coordinate:CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: UUID().uuidString)
        locationManager.requestState(for: region)
    }
    
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func isAlwaysAuthorization() -> Bool {
        return locationManager.authorizationStatus == .authorizedAlways
    }
    
}

extension LocationService:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate?.didEnterRegion(region)
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        delegate?.didDetermineState(state, for: region)
    }
   
}



