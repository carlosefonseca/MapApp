//
//  MarkerAnnotationView.swift
//  Map
//
//  Created by carlos.fonseca on 22/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import UIKit
import MapKit

class MarkerAnnotationView: MKMarkerAnnotationView {

    weak var mapView : MKMapView?
    
    lazy var imgView: UIImageView = {
        let v = UIImageView()
        addSubview(v)
        return v
    }()

    func set(image: UIImage) {
        markerTintColor = UIColor.clear
        glyphTintColor = UIColor.clear

        imgView.image = image
        imgView.frame.size = image.size
        imgView.frame.origin = CGPoint(x: -image.size.width / 2 + 14, y: -image.size.height + 30)
        
//        imgView.isUserInteractionEnabled = true
//        let tapRec = UITapGestureRecognizer(target: self, action: #selector(tap))
//        imgView.addGestureRecognizer(tapRec)
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        print(point)
//        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
//
//        if let hit = imgView.hitTest(convert(point, to: imgView), with: event) {
//            return hit
//        }
//
//        return nil
//    }
//
//    @objc func tap() {
//        print("YEY")
//        mapView?.selectAnnotation(self.annotation!, animated: true)
//    }
}
