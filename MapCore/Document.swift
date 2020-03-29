//
//  Document.swift
//  Map
//
//  Created by carlos.fonseca on 22/03/2020.
//  Copyright © 2020 carlosefonseca. All rights reserved.
//

import UIKit
import GEOSwift
import GEOSwiftMapKit
import MapKit

public class Document: UIDocument, ObservableObject {
    @Published public var points: [AppFeature] = []
    @Published public var pointAnnotations: [AppAnnotation] = []
    @Published public var isDownloadingImages = false
    @Published public var selectedPoint: AppFeature? = nil
    @Published public var selectedAnnotation: AppAnnotation? = nil

    override public func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }

    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        print(typeName!)

        if let data = contents as? Data {
            Parser().load(data: data, document: self)
        }

    }

    public func select(point: AppFeature) {
        self.selectedPoint = point
        let idx = self.points.firstIndex(where: { $0 == point })!
        self.selectedAnnotation = self.pointAnnotations[idx]
    }

    public func annotation(forFeature feature: AppFeature) -> AppAnnotation {
        let idx = self.points.firstIndex(where: { $0 == feature })!
        return self.pointAnnotations[idx]
    }
    
    func select(annotation: AppAnnotation) {

    }
}

class Parser {
    fileprivate func createPointAnnotation(_ p: (Point), _ f: AppFeature) -> AppAnnotation? {
        let annotation = AppAnnotation(point: p)
        annotation.title = f.title ?? "Unnamed"
        annotation.subtitle = f.subtitle
        annotation.imageUrl = f.imageUrl
        annotation.imageSymbol = f.imageSymbol
        annotation.point = f
        return annotation
    }

    func load(data: Data, document: Document) {
        let jsonDecoder = JSONDecoder()

        if let featureCollection = try? jsonDecoder.decode(FeatureCollection.self, from: data) {

            let features: [Feature] = featureCollection.features
            document.points = features.compactMap { AppFeature(feature: $0) }

            document.pointAnnotations = document.points.compactMap { f in
                switch (f.geometry) {
                case .point(let p):
                    return createPointAnnotation(p, f)
                default:
                    print("Not supported: \(f)")
                    return nil
                }
            }
        }
    }
}

public struct AppFeature {
    public let feature: Feature

    public var geometry: Geometry? {
        feature.geometry
    }

    fileprivate func getStringProperty(named name: String) -> String? {
        if case .string(let str) = feature.properties?[name] {
            return str.replacingOccurrences(of: "\\n", with: "\n")
        }
        return nil
    }

    public var title: String? { getStringProperty(named: "title") }
    public var subtitle: String? { getStringProperty(named: "subtitle") }
    public var description: String? { getStringProperty(named: "description") }
    public var imageUrl: URL? {
        if let url = getStringProperty(named: "image_url") {
            return URL(string: url)
        }
        return nil
    }

    var imageSymbol: String? { getStringProperty(named: "image_symbol") }
}

extension AppFeature: Equatable { }

public class AppAnnotation: MKPointAnnotation {
    public var imageUrl: URL?
    public var imageSymbol: String?
    public var point: AppFeature?
}
