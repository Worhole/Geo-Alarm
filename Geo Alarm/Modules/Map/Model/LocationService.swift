


import MapKit

protocol LocationServiceDelegate:AnyObject {
    func didEnterRegion(_ region: CLRegion)
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
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        locationManager.startMonitoring(for: region)

    }
    
    func checkState(coordinate:CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: UUID().uuidString)
        let currentLocation = locationManager.location
        guard let distance = currentLocation?.distance(from: CLLocation(latitude: region.center.latitude, longitude:  region.center.longitude)) else {
            return }
        if distance <= region.radius {
            NotificationCenter.default.post(name: NSNotification.Name("locationInside"), object: nil)
        }
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
}
