//
//  ViewController.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-12.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var mapView = MKMapView()
    var presenter:MapViewPresenterProtocol!
    let locationPermissionVC = LocationPermissionViewController()
    
    lazy var searchButton:UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.setImage(UIImage(systemName: "location.magnifyingglass"), for: .normal)
        $0.tintColor = .white
        $0.layer.cornerRadius = 17
        $0.addTarget(self, action: #selector(goToSearch), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var showUserLocationButton:UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.setImage(UIImage(systemName: "location.fill"), for: .normal)
        $0.tintColor = .white
        $0.layer.cornerRadius = 17
        $0.addTarget(self, action: #selector(showUserLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var showAlarmLocationButton:UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.setImage(UIImage(systemName: "alarm.fill"), for: .normal)
        $0.tintColor = .white
        $0.layer.cornerRadius = 17
        $0.isHidden = true
        $0.addTarget(self, action: #selector(showAlarmLocation), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNotificationObserver()
        setupGestures()
        mapView.delegate = self
        restoreCircleIfNeeded()
        mapView.userTrackingMode = .follow
        restoreButtonVisibilityState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
}
extension MapViewController:MapViewProtocol{
    
    func dismissPermissionScreen() {
        locationPermissionVC.dismiss(animated: true)
    }
    
    func showPermissionScreen() {
        locationPermissionVC.modalPresentationStyle = .overFullScreen
        present(locationPermissionVC, animated: true)
    }
    
    func setupUserLocation() {
        mapView.showsUserLocation = true
    }

    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let circleOverlay = MKCircle(center: coordinate, radius: 50)
        mapView.addOverlay(circleOverlay)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func showMapSelectionMonitor(coordinate: CLLocationCoordinate2D) {
        let view = MapSelectionMonitorViewController()
        let locationService = LocationService()
        let presenter = MapSelectionMonitorPresenter(view: view, locationService: locationService, coordinate: coordinate)
        view.presenter = presenter
        
        
        let nav = UINavigationController(rootViewController: view)
        nav.isModalInPresentation = true
        let defaultDetent = UISheetPresentationController.Detent.custom { context in
            0.2 * context.maximumDetentValue
        }
        if let sheet = nav.sheetPresentationController {
            sheet.preferredCornerRadius = 20
            sheet.detents = [defaultDetent]
            sheet.largestUndimmedDetentIdentifier = defaultDetent.identifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        navigationController?.present(nav, animated: true)
    }
    
    func showStoptMonitoringSheet(coordinate: CLLocationCoordinate2D) {
        
        let view = MonitoringLocationDetailsViewController()
        let locationService = LocationService()
        let presenter = MonitoringLocationDetailsPresenter(view: view, locationService: locationService, coordinate: coordinate)
        view.presenter = presenter
        
        let nav = UINavigationController(rootViewController: view)
        nav.isModalInPresentation = true
        let defaultDetent = UISheetPresentationController.Detent.custom { context in
            0.2 * context.maximumDetentValue
        }
        if let sheet = nav.sheetPresentationController {
            sheet.preferredCornerRadius = 20
            sheet.detents = [defaultDetent]
            sheet.largestUndimmedDetentIdentifier = defaultDetent.identifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        navigationController?.present(nav, animated: true)
    }
}

extension MapViewController:SearchLocationDelegate {
    func selectLocation(at coordinate: CLLocationCoordinate2D) {
        presenter.didSelectLocation(at: coordinate)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController{
    private func setupLayout(){
        
        view.addSubview(mapView)
        view.addSubview(searchButton)
        view.addSubview(showAlarmLocationButton)
        view.addSubview(showUserLocationButton)
        
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 140),
            searchButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            
            showAlarmLocationButton.topAnchor.constraint(equalTo: searchButton.topAnchor),
            showAlarmLocationButton.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor),
            showAlarmLocationButton.widthAnchor.constraint(equalToConstant: 40),
            showAlarmLocationButton.heightAnchor.constraint(equalToConstant: 40),
            
            showUserLocationButton.topAnchor.constraint(equalTo: showAlarmLocationButton.bottomAnchor,constant: 20),
            showUserLocationButton.trailingAnchor.constraint(equalTo: showAlarmLocationButton.trailingAnchor),
            showUserLocationButton.widthAnchor.constraint(equalToConstant: 40),
            showUserLocationButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    @objc
    func showUserLocation(){
        var mode: MKUserTrackingMode
        switch (mapView.userTrackingMode) {
        case .none:
            mode = .follow
        case .follow:
            mode = .followWithHeading
        case .followWithHeading:
            mode = .none
        @unknown default:
            fatalError("Unknown user tracking mode")
        }
        mapView.userTrackingMode = mode
    }
    @objc
    func goToSearch(){
        let view = SearchViewController()
        let service = SearchLocationService()
        let presenter = SearchLocationPresenter(view: view,service: service)
        view.presenter = presenter
        view.delegate = self

        let nav = UINavigationController(rootViewController: view)
        let defaultDetent = UISheetPresentationController.Detent.custom { context in
            0.99 * context.maximumDetentValue
        }
        if let sheet = nav.sheetPresentationController {
            sheet.preferredCornerRadius = 20
            sheet.detents = [defaultDetent]
            sheet.largestUndimmedDetentIdentifier = defaultDetent.identifier
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        navigationController?.present(nav, animated: true)
    }
    @objc
    func showAlarmLocation(){
        let circle = mapView.overlays.map { $0 as! MKCircle}
        guard let coordinate = circle.first?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController {
    func setupNotificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthStatus), name: NSNotification.Name("willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnnotations), name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOverlays), name: NSNotification.Name("removeOverlays"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("locationInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTapedOnNotification), name: NSNotification.Name("clickedOnTheNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeLongPress), name: NSNotification.Name("removeLongPress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addLongPress), name: NSNotification.Name("addLongPress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveOverlays), name: NSNotification.Name("saveOverlays") , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleIsHiddenButtons), name: NSNotification.Name("toggleIsHiddenButtons") , object: nil)
    }
}

extension MapViewController {
    @objc
    func checkAuthStatus(){
        presenter.checkAuthStatus()
    }
    @objc
    func removeAnnotations(){
        let annotations = mapView.annotations.filter{ !($0 is MKUserLocation) }
        NotificationCenter.default.post(name: NSNotification.Name("dismissBottomSheet"), object: nil)
        mapView.removeAnnotations(annotations)
    }
    @objc
    func removeOverlays(){
        mapView.removeOverlays(mapView.overlays)
    }
    @objc
    func showAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "you are inside the selected location", message: "select another location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { [self] action in
                self.removeAnnotations()
                self.removeOverlays()
                presenter.stopMonitoring()
            }))
            self.present(alert, animated: true)
        }
    }
    @objc
    func didTapedOnNotification(){
        removeOverlays()
        presenter.stopMonitoring()
    }
    @objc
    func saveOverlays(){
        let overlays = mapView.overlays.compactMap{ $0 as? MKCircle }
        presenter.saveOverlays(overlays: overlays)
    }
    @objc
    func toggleIsHiddenButtons(){
        searchButton.isHidden.toggle()
        showAlarmLocationButton.isHidden.toggle()
        let isSearchButtonHidden = searchButton.isHidden
        UserDefaults.standard.set(isSearchButtonHidden, forKey: "isSearchButtonHidden")
    }
    func restoreButtonVisibilityState() {
        let isSearchHidden = UserDefaults.standard.bool(forKey: "isSearchButtonHidden")
        searchButton.isHidden = isSearchHidden
        showAlarmLocationButton.isHidden = !isSearchHidden
    }
}

extension MapViewController:UIGestureRecognizerDelegate {
    func setupGestures(){
        addLongPress()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGesture)
    }
    @objc func addLongPress(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.name = "longPress"
        longPress.delegate = self
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
    }
    @objc
    func removeLongPress(){
        mapView.gestureRecognizers.map { gestures in
            for gesture in gestures{
                if gesture.name == "longPress"{
                    mapView.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    @objc
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer){
        guard gestureRecognizer.state == .began else {return}
        removeAnnotations()
        removeOverlays()
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        let locationPoint = gestureRecognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(locationPoint, toCoordinateFrom: mapView)
        presenter.didSelectLocation(at: locationCoordinate)
        presenter.displayMonitoringSheet(for: locationCoordinate)
    }
    @objc
    func tapAction(_ gestureRecognizer: UITapGestureRecognizer){
        let tapPoint = gestureRecognizer.location(in: mapView)
        let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        didTapAt(tapCoordinate)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func didTapAt(_ coordinate: CLLocationCoordinate2D){
        let mapPoint = MKMapPoint(coordinate)
        for overlay in mapView.overlays {
            guard let renderer = mapView.renderer(for: overlay) as? ZoneCircle else { return }
            if renderer.contains(mapPoint) {
                presenter.didPressOnZone(at: renderer.overlay.coordinate)
            }
        }
    }
}

extension MapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            return ZoneCircle(overlay: overlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MapViewController{
    func restoreCircleIfNeeded(){
        if let circleInfo = UserDefaults.standard.object(forKey: "circleInfo") as? [[String : CLLocationDegrees]] {
            for info in circleInfo {
                let coordinate = CLLocationCoordinate2D(latitude: info["lat"] ?? 0, longitude: info["lon"] ?? 0)
                let radius = info["radius"] ?? 0
                let circle = MKCircle(center: coordinate, radius: radius)
                mapView.addOverlay(circle)
            }
        }
    }
}
