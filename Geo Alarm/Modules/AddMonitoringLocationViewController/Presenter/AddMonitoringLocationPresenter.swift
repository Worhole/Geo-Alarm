//
//  AddMonitoringLocationPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-19.
//

import MapKit


protocol AddMonitoringLocationViewProtocol:AnyObject{
    func present(lat: String, lon:String)
    func dismissView()
}

protocol AddMonitoringLocationPresenterProtocol:AnyObject{
    init(view:AddMonitoringLocationViewProtocol, locationService:LocationServiceProtocol,coordinate:CLLocationCoordinate2D)
    func addMonitoring()
    func removeMonitoring()
}

class AddMonitoringLocationPresenter:AddMonitoringLocationPresenterProtocol{

    weak var view: AddMonitoringLocationViewProtocol?
    let locationService:LocationServiceProtocol
    let coordinate:CLLocationCoordinate2D
    
    required init(view: any AddMonitoringLocationViewProtocol, locationService: any LocationServiceProtocol, coordinate: CLLocationCoordinate2D) {
        self.locationService = locationService
        self.view = view
        self.coordinate = coordinate
        view.present(lat: String(format: "%6f", coordinate.latitude), lon: String(format: "%6f", coordinate.longitude))
    }
    
    func addMonitoring() {
        locationService.startMonitoring(coordinate: coordinate)
        view?.dismissView()
    }
    
    func removeMonitoring() {
        locationService.stopMonitoring()
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
    }
    
}
