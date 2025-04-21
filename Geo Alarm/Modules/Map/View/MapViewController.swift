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
//MARK: - MapViewProtocol
extension MapViewController:MapViewProtocol{
    
    func dismissPermissionScreen() {
        locationPermissionVC.dismiss(animated: true)
    }
    
    func showPermissionScreen() {
        locationPermissionVC.modalPresentationStyle = .overFullScreen
        present(locationPermissionVC, animated: true)
    }
    
    func setupUserLocation() {
        mapView.showsUserTrackingButton = true
        mapView.showsUserLocation = true
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let circleOverlay = MKCircle(center: coordinate, radius: 50)
        mapView.addOverlay(circleOverlay)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    func showBottomSheet(coordinate: CLLocationCoordinate2D) {
        
        let bottomvc = AddMonitoringLocationViewController()
        let locationService = LocationService()
        let presenter = AddMonitoringLocationPresenter(view: bottomvc, locationService:locationService , coordinate: coordinate)
        bottomvc.presenter = presenter
        
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

extension MapViewController {
    @objc
    func checkAuthStatus(){
        presenter.checkAuthStatus()
    }
}

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
        removeOverlays()
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        let locationPoint = gestureRecognizer.location(in: mapView)
        let locationCoordinate = mapView.convert(locationPoint, toCoordinateFrom: mapView)
        presenter.didLongPress(at: locationCoordinate)
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
}

extension MapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            return ZoneCircle(overlay: overlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


