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
    init(view:MonitoringLocationDetailsViewProtocol,locationService:LocationServiceProtocol, coordinate:CLLocationCoordinate2D,storageService:StorageServiceProtocol)
    func stopMonitoring()
}

class MonitoringLocationDetailsPresenter:MonitoringLocationDetailsPresenterProtocol {
  
    weak var view:MonitoringLocationDetailsViewProtocol?
    let locationService:LocationServiceProtocol
    let storageService:StorageServiceProtocol
    
    required init(view: any MonitoringLocationDetailsViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D, storageService: any StorageServiceProtocol) {
        self.locationService = locationService
        self.view = view
        self.storageService = storageService
        view.present(lat: String(format: "%6f", coordinate.latitude), lon:  String(format: "%6f", coordinate.longitude))
    }
    
    func stopMonitoring() {
        locationService.stopMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("removeOverlays"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("updateButtonVisibilityState"), object: nil)
        storageService.removeCircle()
    }
}
