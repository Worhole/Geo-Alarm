//
//  AddMonitoringLocationPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-19.
//

import MapKit


protocol AddMonitoringLocationViewProtocol:AnyObject{
    func present(lat: String, lon:String)
}

protocol AddMonitoringLocationPresenterProtocol:AnyObject{
    init(view:AddMonitoringLocationViewProtocol, locationService:LocationServiceProtocol,coordinate:CLLocationCoordinate2D,mapView:MKMapView)
    func startMonitoring()
}

class AddMonitoringLocationPresenter:AddMonitoringLocationPresenterProtocol{
 
    weak var view: AddMonitoringLocationViewProtocol?
    let locationService:LocationServiceProtocol
    let coordinate:CLLocationCoordinate2D
    let mapView:MKMapView
    
    required init(view: any AddMonitoringLocationViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D, mapView: MKMapView) {
        self.locationService = locationService
        self.view = view
        self.coordinate = coordinate
        view.present(lat: String(format: "%6f", coordinate.latitude), lon: String(format: "%6f", coordinate.longitude))
        self.mapView = mapView
    }
    
    func startMonitoring() {
        locationService.startMonitoring(coordinate: coordinate)
        locationService.checkState(coordinate: coordinate)
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
  
        let overlays = mapView.overlays.compactMap { $0 as? MKCircle }
        let circleInfo = overlays.map {
            [
                "lat":$0.coordinate.latitude,
                "lon":$0.coordinate.longitude,
                "radius":$0.radius
            ]
        }
        UserDefaults.standard.set(circleInfo, forKey: "circleInfo")
    }
   
}
