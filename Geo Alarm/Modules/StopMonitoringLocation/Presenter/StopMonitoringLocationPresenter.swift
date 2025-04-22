//
//  StopMonitoringPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-22.
//

import MapKit


protocol StopMonitoringLocationViewProtocol:AnyObject{
    func present(lat: String, lon:String)
}

protocol StopMonitoringLocationPresenterProtocol:AnyObject {
    init(view:StopMonitoringLocationViewProtocol,locationService:LocationServiceProtocol, coordinate:CLLocationCoordinate2D)
    func stopMonitoring()
}

class StopMonitoringLocationPresenter:StopMonitoringLocationPresenterProtocol {

    weak var view:StopMonitoringLocationViewProtocol?
    let locationService:LocationServiceProtocol
    
    required init(view: any StopMonitoringLocationViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D) {
        self.locationService = locationService
        self.view = view
        view.present(lat: String(format: "%6f", coordinate.latitude), lon:  String(format: "%6f", coordinate.longitude))
    }
    
    func stopMonitoring() {
        locationService.stopMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("removeOverlays"), object: nil)
    }
}
