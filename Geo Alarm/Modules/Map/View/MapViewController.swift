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
        setupNotificationObserver()
        setupGestures()
        mapView.delegate = self
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
        mapView.showsUserTrackingButton = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        let circleOverlay = MKCircle(center: coordinate, radius: 50)
        mapView.addOverlay(circleOverlay)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    
    func showStartMonitoringSheet(coordinate: CLLocationCoordinate2D) {
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
    func showStoptMonitoringSheet(coordinate: CLLocationCoordinate2D) {
        
        let bottomvc = StopMonitoringLocationViewController()
        let locationService = LocationService()
        let presenter = StopMonitoringLocationPresenter(view: bottomvc, locationService: locationService, coordinate: coordinate)
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
    func setupNotificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthStatus), name: NSNotification.Name("willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnnotations), name: NSNotification.Name("removeAnnotation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOverlays), name: NSNotification.Name("removeOverlays"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name("locationInside"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTapedOnNotification), name: NSNotification.Name("clickedOnTheNotification"), object: nil)
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
}

extension MapViewController:UIGestureRecognizerDelegate {
    func setupGestures(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGesture)
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


