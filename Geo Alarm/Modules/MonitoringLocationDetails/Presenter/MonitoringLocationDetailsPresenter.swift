//
//  StopMonitoringPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-22.
//

import MapKit


protocol MonitoringLocationDetailsViewProtocol:AnyObject{
    func present(lat: String, lon:String)
}

protocol MonitoringLocationDetailsPresenterProtocol:AnyObject {
    init(view:MonitoringLocationDetailsViewProtocol,locationService:LocationServiceProtocol, coordinate:CLLocationCoordinate2D)
    func stopMonitoring()
}

class MonitoringLocationDetailsPresenter:MonitoringLocationDetailsPresenterProtocol {

    weak var view:MonitoringLocationDetailsViewProtocol?
    let locationService:LocationServiceProtocol
    
    required init(view: any MonitoringLocationDetailsViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D) {
        self.locationService = locationService
        self.view = view
        view.present(lat: String(format: "%6f", coordinate.latitude), lon:  String(format: "%6f", coordinate.longitude))
    }
    
    func stopMonitoring() {
        locationService.stopMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("removeOverlays"), object: nil)
        UserDefaults.standard.removeObject(forKey: "circleInfo")
    }
}
