//
//  ContentView.swift
//  MapViewTutorial
//
//  Created by Duy Bui on 11/1/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import MapCore
import MapKit
import SDWebImage
import SDWebImageMapKit
import SwiftUI

func ==(lhs: MapView.Camera, rhs: MapView.Camera) -> Bool {
    switch (lhs, rhs) {
    case (.all, .all), (.free, .free):
        return true
    case (let .single(lAnn), .single(let rAnn)):
        return lAnn == rAnn
    case (let .multiple(lAnn), .multiple(let rAnn)):
        return lAnn == rAnn
    default:
        return false
    }
}

struct MapView: UIViewRepresentable {
    enum Camera: Equatable {
        case all
        case single(annotation: AppAnnotation)
        case multiple(annotations: [AppAnnotation])
        case free
    }

    var onSelect: (AppFeature) -> Void
    @EnvironmentObject var state: Document
    @EnvironmentObject var viewState: ViewState

    let mapEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 100, left: 50, bottom: 50, right: 50)

    func makePadding() -> UIEdgeInsets {
        return UIEdgeInsets(top: mapEdgePadding.top,
                            left: mapEdgePadding.left + viewState.leftPad,
                            bottom: mapEdgePadding.bottom + viewState.bottomPad,
                            right: mapEdgePadding.right)
    }

    var locationManager = CLLocationManager()

    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if uiView.annotations.isEmpty {
            uiView.addAnnotations(state.pointAnnotations)
        }
        switch viewState.camera {
        case .all:
            uiView.setVisibleMapRectToFitAllAnnotations(edgePadding: makePadding())
        case .single(let annotation):
            uiView.selectAnnotation(annotation, animated: true)
            uiView.setVisibleMapRectToFitAnnotations([annotation], edgePadding: makePadding())
        case .multiple(let annotations):
            uiView.selectedAnnotations = annotations
            uiView.setVisibleMapRectToFitAnnotations(annotations, edgePadding: makePadding())
        default:
            break
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        let annotationViewReuseIdentifierImageUrl = "url"
        let annotationViewReuseIdentifierPin = "pin"

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? AppAnnotation else {
                return nil
            }

            if let url = ann.imageUrl {
                var annotationView: MarkerAnnotationView?

                annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIdentifierImageUrl) as? MarkerAnnotationView
                    ?? MarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseIdentifierImageUrl)

                SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image: UIImage?, _, _, _, _, _) in
                    let img = image!.resize(withSize: CGSize(width: 50, height: 50), contentMode: .contentAspectFill)!
                    let img2 = self.makeFrame(forImage: img, label: nil)
                    annotationView?.set(image: img2.0)
                }

                annotationView?.annotation = annotation
                annotationView?.mapView = mapView
                annotationView?.canShowCallout = true

                return annotationView

            } else {
                let marker = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIdentifierPin) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseIdentifierPin)

                if let symbol = ann.imageSymbol {
                    marker.glyphImage = UIImage(systemName: symbol)
                    marker.glyphTintColor = UIColor.green
                }

                return marker
            }
        }

        func mapViewRegionDidChangeFromUserInteraction(mapView: MKMapView) -> Bool {
            if let gestureRecognizers = mapView.subviews.first?.gestureRecognizers {
                return gestureRecognizers.contains { (gr) -> Bool in
                    gr.state == .ended || gr.state == .changed
                }
            }
            return false
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            if case .free = parent.viewState.camera {} else {
                if mapViewRegionDidChangeFromUserInteraction(mapView: mapView) {
                    parent.viewState.camera = .free
                }
            }
        }
        
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            if case .free = parent.viewState.camera {} else {
//                if mapViewRegionDidChangeFromUserInteraction(mapView: mapView) {
//                    parent.viewState.camera = .free
//                }
//            }
//        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            let ann = view.annotation as! AppAnnotation
            parent.onSelect(ann.point!)
        }

        func makeFrame(forImage image: UIImage, withShadow shadow: Bool = false, label: String? = nil) -> (UIImage, CGPoint) {
            let imageSize: CGSize = image.size

            let topPadding = CGFloat(5)
            let padding = CGFloat(15)

            let rect = CGRect(x: padding, y: topPadding, width: imageSize.width, height: imageSize.height)
            let triangleSize = CGSize(width: 20, height: 5)
            let triangle = CGRect(origin: CGPoint(x: rect.midX - triangleSize.width / 2, y: rect.maxY), size: triangleSize)

            let textRect: CGRect
            if let label = label {
                let h = textHeight(text: label, maxSize: CGSize(width: rect.width + 2 * padding, height: 100))
                textRect = CGRect(x: 0, y: triangle.maxY, width: rect.width + 2 * padding, height: h)
            } else {
                textRect = CGRect(x: 0, y: triangle.maxY, width: rect.width + 2 * padding, height: 0)
            }

            let canvasSize = CGSize(width: textRect.width, height: textRect.maxY)

            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let bottomOfTriangle = CGPoint(x: triangle.midX, y: triangle.maxY)
            let diff = CGPoint(x: center.x - bottomOfTriangle.x, y: center.y - bottomOfTriangle.y)

            let img = UIGraphicsImageRenderer(size: canvasSize).image { ctx in

                let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 5)
                let t = drawTriangle(rect: triangle)
                bezierPath.append(t)

                ctx.cgContext.saveGState()
                if shadow {
                    ctx.cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 6, color: UIColor.black.cgColor)
                } else {
                    ctx.cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 4, color: UIColor.black.withAlphaComponent(0.4).cgColor)
                }

                image.averageColor2!.setFill()
                bezierPath.fill()

                bezierPath.addClip()

                ctx.cgContext.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)

                image.draw(in: rect)
                ctx.cgContext.restoreGState()

                if let label = label {
                    draw(text: label, at: textRect)
                }
            }

            return (img, diff)
        }

        func drawTriangle(rect: CGRect) -> UIBezierPath {
            let x: CGFloat = rect.origin.x
            let y: CGFloat = rect.origin.y
            let w: CGFloat = rect.width
            let h: CGFloat = rect.height

            let polygonPath = UIBezierPath()
            polygonPath.move(to: CGPoint(x: x + w / 2, y: y + h))
            polygonPath.addLine(to: CGPoint(x: x + 0, y: y + 0))
            polygonPath.addLine(to: CGPoint(x: x + w, y: y + 0))
            polygonPath.addLine(to: CGPoint(x: x + w / 2, y: y + h))
            polygonPath.close()
            return polygonPath
        }

        var textAttributes: [NSAttributedString.Key: NSObject] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            return [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(10), weight: .semibold),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
            ]
        }

        func textHeight(text: String, maxSize: CGSize) -> CGFloat {
            return NSAttributedString(string: text, attributes: textAttributes).boundingRect(with: maxSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], context: nil).size.height
        }

        func draw(text: String, at textRect: CGRect) {
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.setShadow(offset: .zero, blur: 5, color: UIColor.white.cgColor)

            UIColor.white.setStroke()
            UIColor.black.setFill()
            text.draw(with: textRect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: textAttributes, context: nil)

            ctx.setShadow(offset: .zero, blur: 0, color: UIColor.clear.cgColor)
        }

        func drawCenterPoint(centerCoords: CGPoint, offsetCoords: CGPoint) {
            let centerCoords = CGPoint(x: centerCoords.x - offsetCoords.x, y: centerCoords.y - offsetCoords.y)
            let circle = UIBezierPath(ovalIn: CGRect(origin: centerCoords, size: CGSize(width: 2, height: 2)))
            UIColor.red.withAlphaComponent(0.7).setStroke()
            UIColor.brown.withAlphaComponent(0.5).setFill()

            circle.fill()
            circle.stroke()
        }
    }
}

struct MapViewStuff: View {
    var body: some View {
        MapView(onSelect: { _ in })
    }
}

struct MapViewStuff_Previews: PreviewProvider {
    static var previews: some View {
        MapViewStuff()
    }
}
