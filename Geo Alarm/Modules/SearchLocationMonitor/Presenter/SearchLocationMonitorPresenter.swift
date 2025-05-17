//
//  SearchLocationMonitorPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-16.
//

import MapKit

protocol SearchLocationMonitorViewProtocol:AnyObject{
    func present(title:String?,subtitle:String?,lat:String,lon:String)
}

protocol SearchLocationMonitorPresenterProtocol:AnyObject{
    init(view:SearchLocationMonitorViewProtocol,locationService:LocationServiceProtocol,mapItem:MKMapItem)
    func startMonitoring()
}

class SearchLocationMonitorPresenter: SearchLocationMonitorPresenterProtocol {
    
    let view:SearchLocationMonitorViewProtocol
    let locationService:LocationServiceProtocol
    let mapItem:MKMapItem
    
    required init(view: any SearchLocationMonitorViewProtocol, locationService: any LocationServiceProtocol, mapItem: MKMapItem) {
        self.view = view
        self.locationService = locationService
        self.mapItem = mapItem
        view.present(title: mapItem.placemark.name, subtitle: mapItem.placemark.title, lat: String(format: "%6f", mapItem.placemark.coordinate.latitude), lon: String(format: "%6f", mapItem.placemark.coordinate.longitude ))
    }
    func startMonitoring() {
        locationService.startMonitoring(coordinate: mapItem.placemark.coordinate)
        locationService.checkState(coordinate: mapItem.placemark.coordinate)
        NotificationCenter.default.post(name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("saveOverlays"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("toggleIsHiddenButtons"), object: nil)
    }
}

