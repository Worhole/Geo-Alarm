//
//  AddMonitoringLocationPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-19.
//

import MapKit

protocol MapSelectionMonitorViewProtocol:AnyObject{
    func present(lat: String, lon:String)
}

protocol MapSelectionMonitorPresenterProtocol:AnyObject{
    init(view: any MapSelectionMonitorViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D)
    func startMonitoring()
}

class MapSelectionMonitorPresenter:MapSelectionMonitorPresenterProtocol{
 
    weak var view: MapSelectionMonitorViewProtocol?
    let locationService:LocationServiceProtocol
    let coordinate:CLLocationCoordinate2D
    
    required init(view: any MapSelectionMonitorViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D) {
        self.locationService = locationService
        self.view = view
        self.coordinate = coordinate
        view.present(lat: String(format: "%6f", coordinate.latitude), lon: String(format: "%6f", coordinate.longitude ))
    }
    
    func startMonitoring() {
        locationService.startMonitoring(coordinate: coordinate)
        locationService.checkState(coordinate: coordinate)
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("saveCircle"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("updateButtonVisibilityState"), object: nil)
    }
}
