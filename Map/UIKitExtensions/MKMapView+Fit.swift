//
//  MKMapView+Fit.swift
//  Map
//
//  Created by carlos.fonseca on 21/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import MapKit

extension MKMapView {
    func setVisibleMapRectToFitAnnotations(_ annotationSet: [MKAnnotation],
                                           animated: Bool = true,
                                           shouldIncludeUserAccuracyRange: Bool = true,
                                           shouldIncludeOverlays: Bool = true,
                                           edgePadding: UIEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)) {
        var mapOverlays = overlays

        if shouldIncludeUserAccuracyRange, let userLocation = userLocation.location {
            let userAccuracyRangeCircle = MKCircle(center: userLocation.coordinate, radius: userLocation.horizontalAccuracy)
            mapOverlays.append(MKOverlayRenderer(overlay: userAccuracyRangeCircle).overlay)
        }

        if shouldIncludeOverlays {
            let annotations = annotationSet.filter { !($0 is MKUserLocation) }
            annotations.forEach { annotation in
                let circle = MKCircle(center: annotation.coordinate, radius: 1)
                mapOverlays.append(circle)
            }
        }

        let zoomRect = MKMapRect(bounding: mapOverlays)
        setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: animated)
    }

    func setVisibleMapRectToFitAllAnnotations(animated: Bool = true,
                                              shouldIncludeUserAccuracyRange: Bool = true,
                                              shouldIncludeOverlays: Bool = true,
                                              edgePadding: UIEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)) {
        let annotationSet: [MKAnnotation] = annotations

        setVisibleMapRectToFitAnnotations(annotationSet,
                                          animated: animated,
                                          shouldIncludeUserAccuracyRange: shouldIncludeUserAccuracyRange,
                                          shouldIncludeOverlays: shouldIncludeOverlays,
                                          edgePadding: edgePadding)
    }
}

extension MKMapRect {
    init(bounding overlays: [MKOverlay]) {
        self = .null
        overlays.forEach { overlay in
            let rect: MKMapRect = overlay.boundingMapRect
            self = self.union(rect)
        }
    }
}
