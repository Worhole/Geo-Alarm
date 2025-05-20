//
//  SearchPresenter.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-09.
//

import UIKit
import MapKit

protocol SearchLocationViewProtocol:AnyObject{
    func showSearchResults(_ searchTitles:[String])
    func failure(_ error:Error)
    func presentSearchLocationMonitor(items:[MKMapItem])
}

protocol SearchLocationPresenterProtocol:AnyObject{
    init(view:SearchLocationViewProtocol,searchLocationService:SearchLocationServiceProtocol, storageService:StorageServiceProtocol)
    func searchLocation(for text:String?)
    func getMapItem(for locationName:String?)
    func addSearchRequest(_ request:String?)
    func removeSearchRequest(at index:Int)
    func loadSearchHistory()->[String]
}

class SearchLocationPresenter:SearchLocationPresenterProtocol{
   
    var view:SearchLocationViewProtocol
    var searchLocationService:SearchLocationServiceProtocol
    var storageService:StorageServiceProtocol
    
    required init(view: any SearchLocationViewProtocol, searchLocationService: any SearchLocationServiceProtocol, storageService: any StorageServiceProtocol) {
        self.view = view
        self.searchLocationService = searchLocationService
        self.storageService = storageService
    }
    
    func searchLocation(for text: String?) {
        searchLocationService.searchLocation(searchText: text) { result in
            switch result {
            case .success(let success):
                let titles = success.map{$0.title}
                self.view.showSearchResults(titles)
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
    
    func addSearchRequest(_ request:String?){
        guard let request = request else {return}
        storageService.addSearchHistoryItem(request)
    }
   
    func removeSearchRequest(at index: Int) {
        storageService.removeSearchHistoryItem(at: index)
    }
    func loadSearchHistory()->[String] {
        return storageService.loadSearchHistory()
    }
}
