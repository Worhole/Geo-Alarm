//
//  PulsingCircle.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-17.
//

import MapKit
import UIKit

class ZoneCircle: MKOverlayPathRenderer {
    override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
        self.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
        self.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
        self.lineWidth = 2
        self.alpha = 0.6
    }
    override func createPath() {
        guard let circle = overlay as? MKCircle else { return }

        let centerMapPoint = MKMapPoint(circle.coordinate)
        let center = point(for: centerMapPoint)

        let metersPerPoint = MKMetersPerMapPointAtLatitude(circle.coordinate.latitude)
        let radiusInPoints = CGFloat(circle.radius) / CGFloat(metersPerPoint)

        let path = UIBezierPath(ovalIn: CGRect(
            x: center.x - radiusInPoints,
            y: center.y - radiusInPoints,
            width: radiusInPoints * 2,
            height: radiusInPoints * 2
        ))
        self.path = path.cgPath
    }
    
    func contains(_ mapPoint: MKMapPoint) -> Bool {
        let pointInRenderer = self.point(for: mapPoint)
        return path.contains(pointInRenderer)
    }
}
