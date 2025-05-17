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
    func showMapSelectionMonitor(coordinate: CLLocationCoordinate2D)
    func showStoptMonitoringSheet(coordinate:CLLocationCoordinate2D)
    func restoreButtonVisibilityState(isSearchButtonHidden:Bool?)
    func restoreCircleIfNeeded(circle:MKCircle?)
    
}

protocol MapViewPresenterProtocol:AnyObject {
    init(view: MapViewProtocol, locationService:LocationServiceProtocol, storageService:StorageServiceProtocol)
    func didSelectLocation(at coordinate: CLLocationCoordinate2D)
    func displayMonitoringSheet(for coordinate:CLLocationCoordinate2D)
    func didPressOnZone(at coordinate:CLLocationCoordinate2D)
    func stopMonitoring()
    func checkAuthStatus()
    func saveCircle(circle: MKCircle)
    func updateButtonVisibilityState(isSearchButtonHidden:Bool)
}

class MapPresenter:MapViewPresenterProtocol {
    
    
    weak var view:MapViewProtocol?
    let locationService:LocationServiceProtocol
    let storageService:StorageServiceProtocol
    
    required init(view: any MapViewProtocol, locationService: any LocationServiceProtocol, storageService: any StorageServiceProtocol) {
        self.view = view
        self.locationService = locationService
        self.storageService = storageService
        locationService.delegate = self
        view.restoreButtonVisibilityState(isSearchButtonHidden: storageService.catchButtonVisibilityState())
        view.restoreCircleIfNeeded(circle: storageService.catchCircle())
    }
    
    func didSelectLocation(at coordinate: CLLocationCoordinate2D) {
        view?.addAnnotation(at: coordinate)
    }
    func displayMonitoringSheet(for coordinate: CLLocationCoordinate2D) {
        view?.showMapSelectionMonitor(coordinate: coordinate)
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
    
    func saveCircle(circle: MKCircle) {
        storageService.saveCircle(circle: circle)
    }
    
    func updateButtonVisibilityState(isSearchButtonHidden: Bool) {
        storageService.saveButtonVisibilityState(visibilityState: isSearchButtonHidden)
    }
}

extension MapPresenter:LocationServiceDelegate {
    func didEnterRegion(_ region: CLRegion) {
        NotificationCenter.default.post(name: NSNotification.Name("locationEnter"), object: nil)
    }
}
