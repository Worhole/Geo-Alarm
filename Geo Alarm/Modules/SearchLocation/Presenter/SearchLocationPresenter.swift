//
//  SearchPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-09.
//

import UIKit
import MapKit

protocol SearchLocationViewProtocol:AnyObject{
    func success(_ searchComletion:[MKLocalSearchCompletion])
    func failure(_ error:Error)
    func presentSearchLocationMonitor(items:[MKMapItem])
}

protocol SearchLocationPresenterProtocol:AnyObject{
    init(view:SearchLocationViewProtocol,service:SearchLocationServiceProtocol)
    func searchLocation(for text:String?)
    func getMapItem(for locationName:String?)
}

class SearchLocationPresenter:SearchLocationPresenterProtocol{
 
    var view:SearchLocationViewProtocol
    var searchLocationService:SearchLocationServiceProtocol
  
    
    required init(view: any SearchLocationViewProtocol, service: any SearchLocationServiceProtocol) {
        self.view = view
        self.searchLocationService = service
    }
    
    func searchLocation(for text: String?) {
        searchLocationService.searchLocation(searchText: text) { result in
            switch result {
            case .success(let success):
                self.view.success(success)
            case .failure(let error):
                self.view.failure(error)
            }
        }
    }
    
    func getMapItem(for locationName: String?) {
        searchLocationService.getMapItem(locationName: locationName) { result in
            switch result {
            case .success(let success):
                self.view.presentSearchLocationMonitor(items: success)
            case .failure(let error):
                self.view.failure(error)
            }
        }
    }
}
