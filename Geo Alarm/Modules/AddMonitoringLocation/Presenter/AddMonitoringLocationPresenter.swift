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
    init(view:AddMonitoringLocationViewProtocol, locationService:LocationServiceProtocol,coordinate:CLLocationCoordinate2D)
    func startMonitoring()
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
    
    func startMonitoring() {
        locationService.startMonitoring(coordinate: coordinate)
        locationService.checkState(coordinate: coordinate)
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
    }
   
}
