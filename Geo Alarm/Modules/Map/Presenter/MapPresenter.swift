//
//  MapPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-18.
//

import Foundation

protocol MapViewProtocol:AnyObject {
}

protocol MapViewPresenterProtocol:AnyObject {
    init(view: MapViewProtocol, locationService:LocationServiceProtocol)
}

class MapPresenter:MapViewPresenterProtocol {
    
    let view:MapViewProtocol
    let locationService:LocationServiceProtocol
    
    required init(view: any MapViewProtocol, locationService: any LocationServiceProtocol) {
        self.view = view
        self.locationService = locationService
    }
}
