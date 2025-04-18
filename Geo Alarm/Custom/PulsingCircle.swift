//
//  PulsingCircle.swift
//  Geo Alarm
//
//  Created by 71m3 on 2025-04-17.
//

import MapKit
import UIKit

class PulsingCircle: MKOverlayPathRenderer {


    private var pulseRadiusMultiplier: CGFloat = 1.0
    private var increasing = true

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
        let animatedRadius = CGFloat(circle.radius) / CGFloat(metersPerPoint) * pulseRadiusMultiplier

        let path = UIBezierPath(ovalIn: CGRect(
            x: center.x - animatedRadius,
            y: center.y - animatedRadius,
            width: animatedRadius * 2,
            height: animatedRadius * 2
        ))

        self.path = path.cgPath
    }

}
