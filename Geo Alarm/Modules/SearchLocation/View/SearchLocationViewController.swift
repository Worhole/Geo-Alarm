//
//  SearchViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-05-09.
//

import UIKit
import MapKit

protocol SearchLocationDelegate:AnyObject{
    func selectLocation(at coordinate:CLLocationCoordinate2D)
}

enum SearchTableContentMode{
    case history, results
}

class SearchViewController: UIViewController {
    
    var presenter:SearchLocationPresenter!
    var items = [String]()
    weak var delegate:SearchLocationDelegate!
    var contentMode:SearchTableContentMode = .results
    
    lazy var searchLocationBar:UISearchBar = {
        $0.placeholder = "Search here"
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UISearchBar())
    
    lazy var searchLocationResultTableView:UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(SearchLocationRestultCell.self, forCellReuseIdentifier: SearchLocationRestultCell.reuseId)
        $0.separatorStyle = .none
        return $0
    }(UITableView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupRequestHistory()
    }
}

extension SearchViewController:SearchLocationViewProtocol {
    
    func showSearchResults(_ searchTitles: [String]) {
        items = searchTitles
        contentMode = .results
        searchLocationResultTableView.reloadData()
    }
    
    func presentSearchLocationMonitor(items: [MKMapItem]) {
        guard let presentingVC = self.presentingViewController else {return}
        self.dismiss(animated: true) {
            guard let mapItem = items.first else {return}
            
            self.delegate.selectLocation(at: mapItem.placemark.coordinate)
            
            let view = SearchLocationMonitorViewController()
            let locationService = LocationService()
            let presenter = SearchLocationMonitorPresenter(view: view, locationService: locationService, mapItem: mapItem)
            view.presenter = presenter
            
            let nav = UINavigationController(rootViewController: view)
            nav.isModalInPresentation = true
            view.loadViewIfNeeded()
            
            let defaultDetent = UISheetPresentationController.Detent.custom { _ in
                return view.preferredContentSize.height
            }
            
            if let sheet = nav.sheetPresentationController {
                sheet.preferredCornerRadius = 20
                sheet.detents = [defaultDetent]
                sheet.largestUndimmedDetentIdentifier = defaultDetent.identifier
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            presentingVC.present(nav, animated: true)
        }
    }
    func failure(_ error: any Error) {
        print(error as Any)
    }
}

extension SearchViewController{
    func setupRequestHistory(){
        items = presenter.loadSearchHistory()
        contentMode = .history
        searchLocationResultTableView.reloadData()
    }
}

extension SearchViewController {
    func setupLayout(){
        navigationItem.titleView = searchLocationBar
        navigationItem.titleView?.backgroundColor = .systemBackground
        view.addSubview(searchLocationResultTableView)
        
        NSLayoutConstraint.activate([
            searchLocationResultTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchLocationResultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchLocationResultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchLocationResultTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SearchViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.addSearchRequest(items[indexPath.row])
        presenter.getMapItem(for: items[indexPath.row])
    }
}

extension SearchViewController:UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = .onDrag
    }
}

extension SearchViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchLocationRestultCell.reuseId) as! SearchLocationRestultCell
        let title = items[indexPath.row]
        cell.configue(title: title)
        
        if contentMode == .history {
            cell.isXmarkButtonHidden(false)
            cell.xmarkTapped = { [weak self, weak tableView] in
                guard let self = self,
                        let tableView = tableView,
                        let currentIndexPath = tableView.indexPath(for: cell)
                else {return}
                self.items.remove(at: currentIndexPath.row)
                self.presenter.removeSearchRequest(at: currentIndexPath.row)
                self.searchLocationResultTableView.deleteRows(at: [currentIndexPath], with: .automatic)
            }
        }else{
            cell.isXmarkButtonHidden(true)
            cell.xmarkTapped = nil
        }
        return cell
    }
}

extension SearchViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == true {
            setupRequestHistory()
        }else {
            presenter.searchLocation(for: searchText)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchLocation(for: searchBar.text)
    }
}
