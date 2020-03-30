//
//  Document.swift
//  Map
//
//  Created by carlos.fonseca on 22/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import GEOSwift
import GEOSwiftMapKit
import MapKit
import UIKit

public class Document: UIDocument, ObservableObject {
    @Published public var points: [AppFeature] = []
    @Published public var pointAnnotations: [AppAnnotation] = []
    @Published public var isDownloadingImages = false
    @Published public var selectedPoint: AppFeature? = nil
    @Published public var selectedAnnotation: AppAnnotation? = nil

    public override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }

    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        print(typeName!)

        if let data = contents as? Data {
            Parser().load(data: data, document: self)
        }
    }

    public func select(point: AppFeature) {
        selectedPoint = point
        let idx = points.firstIndex(where: { $0 == point })!
        selectedAnnotation = pointAnnotations[idx]
    }

    public func annotation(forFeature feature: AppFeature) -> AppAnnotation {
        let idx = points.firstIndex(where: { $0 == feature })!
        return pointAnnotations[idx]
    }

    func select(annotation: AppAnnotation) {}
}

class Parser {
    fileprivate func createPointAnnotation(_ f: AppFeature) -> AppAnnotation? {
        return AppAnnotation(feature: f)
    }

    func load(data: Data, document: Document) {
        let jsonDecoder = JSONDecoder()

        if let featureCollection = try? jsonDecoder.decode(FeatureCollection.self, from: data) {
            let features: [Feature] = featureCollection.features
            document.points = features.compactMap { AppFeature(feature: $0) }

            document.pointAnnotations = document.points.map { f in AppAnnotation(feature: f) }
        }
    }
}

public struct AppFeature {
    public var title: String?
    public var subtitle: String?
    public var description: String?
    public var imageUrl: URL?

    public var imageSymbol: String?

    public var lat: CLLocationDegrees
    public var lng: CLLocationDegrees

    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

public extension AppFeature {
    init?(feature: Feature) {
        if case .point(let point) = feature.geometry {
            self.init(title: feature.getStringProperty(named: "title"),
                      subtitle: feature.getStringProperty(named: "subtitle"),
                      description: feature.getStringProperty(named: "description"),
                      imageUrl: feature.getUrlProperty(named: "image_url"),
                      imageSymbol: feature.getStringProperty(named: "image_symbol"),
                      lat: point.y,
                      lng: point.x)
        } else {
            return nil
        }
    }

    init(title: String, subtitle: String? = nil, description: String? = nil, imageUrl: URL? = nil, lat: CLLocationDegrees, lng: CLLocationDegrees) {
        self.init(title: title, subtitle: subtitle, description: description, imageUrl: imageUrl, imageSymbol: nil, lat: lat, lng: lng)
    }
}

extension AppFeature: Equatable {}

public class AppAnnotation: MKPointAnnotation {
    public var imageUrl: URL?
    public var imageSymbol: String?
    public var feature: AppFeature?

    public init(feature: AppFeature) {
        super.init()
        self.feature = feature
        coordinate = feature.coordinate()
        title = feature.title ?? "Unnamed"
        subtitle = feature.subtitle
        imageUrl = feature.imageUrl
        imageSymbol = feature.imageSymbol
    }
}

extension Feature {
    func getStringProperty(named name: String) -> String? {
        if case .string(let str) = properties?[name] {
            return str.replacingOccurrences(of: "\\n", with: "\n")
        }
        return nil
    }

    func getUrlProperty(named name: String) -> URL? {
        if let url = getStringProperty(named: name) {
            return URL(string: url)
        }
        return nil
    }
}
