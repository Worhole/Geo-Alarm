//
//  MapPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-18.
//

import Foundation
import MapKit

protocol MapViewProtocol:AnyObject {
    func showPermissionScreen()
    func dismissPermissionScreen()
    func setupUserLocation()
    func addAnnotation(at coordinate: CLLocationCoordinate2D)
    func showStartMonitoringSheet(coordinate: CLLocationCoordinate2D)
    func showStoptMonitoringSheet(coordinate:CLLocationCoordinate2D)
}

protocol MapViewPresenterProtocol:AnyObject {
    init(view: MapViewProtocol, locationService:LocationServiceProtocol)
    func didLongPress(at coordinate: CLLocationCoordinate2D)
    func didPressOnZone(at coordinate:CLLocationCoordinate2D)
    func stopMonitoring()
    func checkAuthStatus()
}

class MapPresenter:MapViewPresenterProtocol {
    
    weak var view:MapViewProtocol?
    let locationService:LocationServiceProtocol
    
    required init(view: any MapViewProtocol, locationService: any LocationServiceProtocol) {
        self.view = view
        self.locationService = locationService
        locationService.delegate = self
    }
    
    func didLongPress(at coordinate: CLLocationCoordinate2D) {
        view?.addAnnotation(at: coordinate)
        view?.showStartMonitoringSheet(coordinate: coordinate)
    }
    func stopMonitoring() {
        locationService.stopMonitoring()
    }
    func didPressOnZone(at coordinate: CLLocationCoordinate2D) {
        view?.showStoptMonitoringSheet(coordinate: coordinate)
    }
    
    func checkAuthStatus() {
        locationService.requestAlwaysAuthorization()
        if locationService.isAlwaysAuthorization() {
            view?.setupUserLocation()
            view?.dismissPermissionScreen()
        }else {
            view?.showPermissionScreen()
        }
    }
}

extension MapPresenter:LocationServiceDelegate {
    func didEnterRegion(_ region: CLRegion) {
        NotificationCenter.default.post(name: NSNotification.Name("locationEnter"), object: nil)
    }
}
