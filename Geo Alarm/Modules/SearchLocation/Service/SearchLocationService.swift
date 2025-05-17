//
//  SearchLocationService.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-15.
//

import MapKit

enum SearchLocationServiceError:Error{
    case responseError
}

protocol SearchLocationServiceProtocol{
    func getMapItem(locationName: String?, completion:@escaping(Result<[MKMapItem],Error>)->())
    func searchLocation(searchText:String?,completion:@escaping(Result<[MKLocalSearchCompletion],Error>)->())
}

class SearchLocationService:NSObject,SearchLocationServiceProtocol {
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var completionHandler:((Result<[MKLocalSearchCompletion],Error>)->())?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    func getMapItem(locationName: String?, completion:@escaping(Result<[MKMapItem],Error>)->()) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        request.pointOfInterestFilter = .includingAll
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if error != nil {
                completion(.failure(error!))
            }
            guard let response = response else { completion(.failure(SearchLocationServiceError.responseError))
                return}
            completion(.success(response.mapItems))
        }
    }
    
    func searchLocation(searchText:String?,completion:@escaping(Result<[MKLocalSearchCompletion],Error>)->()){
        searchCompleter.queryFragment = searchText ?? ""
        completionHandler = completion
    }
}

extension SearchLocationService:MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completionHandler!(.success(completer.results))
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        completionHandler!(.failure(error))
    }
}
