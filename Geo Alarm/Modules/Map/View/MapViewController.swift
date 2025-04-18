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
    
    let locationManager = CLLocationManager()
    
    let locationPermissionVC = LocationPermissionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthStatus), name: NSNotification.Name("willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnnotations), name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOverlays), name: NSNotification.Name("removeAnnotation"), object: nil)
        setupLongPress()
        mapView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
}
//MARK: - CLLocationManagerDelegate
extension MapViewController:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("пришли в \(region.identifier)")
        NotificationCenter.default.post(name: NSNotification.Name("locationEnter"), object: nil)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        print("ошибка \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("внутри")
            NotificationCenter.default.post(name: NSNotification.Name("locationInside"), object: nil)
        case .outside:
            print("снаружи бро")
        case .unknown :
            print("хз")
        }
    }
}
//MARK: - checkAuthStatus
extension MapViewController {
    @objc
    func checkAuthStatus(){
        locationManager.requestAlwaysAuthorization()
        if locationManager.authorizationStatus != .authorizedAlways {
            locationPermissionVC.modalPresentationStyle = .overFullScreen
            present(locationPermissionVC, animated: true)
        }else {
            locationPermissionVC.dismissPermissionVC()
            mapView.showsUserLocation = true
            mapView.showsUserTrackingButton = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
}
//MARK: - Установка мониторинга
extension MapViewController{
    func setMonitoringRegion(coordinate:CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: "id")
        region.notifyOnEntry = true
        locationManager.delegate = self
        locationManager.startMonitoring(for: region)
        print("мониторинг запущен")
    }
    func checkState(coordinate:CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: "id")
        region.notifyOnEntry = true
        locationManager.delegate = self
        locationManager.startMonitoring(for: region)
        locationManager.requestState(for: region)
    }
}
// MARK: -- обработка локации long press
extension MapViewController {
    func setupLongPress(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
    }
    @objc
    func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer){
       
        guard gestureRecognizer.state == .began else {return}
        removeAnnotations()
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        let locationPoint = gestureRecognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(locationPoint, toCoordinateFrom: mapView)
        addAnnotation(locationCoordinate)
        
        checkState(coordinate: locationCoordinate)
        
        configureSheet(latitude: String(format: "%6f",locationCoordinate.latitude), longitude: String(format: "%6f",locationCoordinate.longitude))
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
    
    private func addAnnotation(_ coordinate:CLLocationCoordinate2D){
        removeOverlays()
        
        let circleOverlay = MKCircle(center: coordinate, radius: 50)
        mapView.addOverlay(circleOverlay)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

// MARK: -- появление bottomSheet, добавление мониторинга  локации
extension MapViewController {
    func configureSheet(latitude:String,longitude:String){
        let bottomvc = AddMonitoringLocationViewController(latitude: latitude, longitude: longitude)
        let nav = UINavigationController(rootViewController: bottomvc)
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



extension MapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            return PulsingCircle(overlay: overlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
