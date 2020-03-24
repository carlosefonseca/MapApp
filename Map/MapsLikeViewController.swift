//
//  MapsLikeViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 30/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI
import MapCore
import OverlayContainer

class MapsLikeViewController: UIViewController {

    let document: Document

    init(document: Document) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum OverlayNotch: Int, CaseIterable {
        case minimum, maximum
    }

    @IBOutlet var backgroundView: UIView!

    private var widthConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!


    lazy var overlayContainerView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        v.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.trailingConstraint = v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        self.trailingConstraint.isActive = true

        self.widthConstraint = NSLayoutConstraint(item: v, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 375)
        self.widthConstraint.priority = UILayoutPriority(rawValue: 700)

        v.addConstraint(self.widthConstraint)
        self.widthConstraint.isActive = false

        return v
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Display the content of the document:
        let view = DocumentView(document: document, dismiss: {
            self.dismiss(animated: true) {
                self.document.close(completionHandler: nil)
            }
        }).environmentObject(document)

        let documentViewController = UIHostingController(rootView: view)

        let overlayController = OverlayContainerViewController()
        overlayController.delegate = self
        overlayController.viewControllers = [SearchViewController(showsCloseAction: false)]
        addChild(overlayController, in: overlayContainerView)
        addChild(documentViewController, in: self.view, at: 0)
    }

    override func viewWillLayoutSubviews() {
        setUpConstraints(for: view.bounds.size)
        super.viewWillLayoutSubviews()
    }

    // MARK: - Private

    private func setUpConstraints(for size: CGSize) {
        if size.width > size.height {
            trailingConstraint.isActive = false
            widthConstraint.isActive = true
        } else {
            trailingConstraint.isActive = true
            widthConstraint.isActive = false
        }
    }

    private func notchHeight(for notch: OverlayNotch, availableSpace: CGFloat) -> CGFloat {
        switch notch {
        case .maximum:
            return availableSpace * 3 / 4
        case .minimum:
            return availableSpace * 1 / 4
        }
    }
}

extension MapsLikeViewController: OverlayContainerViewControllerDelegate {

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
        heightForNotchAt index: Int,
        availableSpace: CGFloat) -> CGFloat {
        let notch = OverlayNotch.allCases[index]
        return notchHeight(for: notch, availableSpace: availableSpace)
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (overlayViewController as? SearchViewController)?.tableView
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
        shouldStartDraggingOverlay overlayViewController: UIViewController,
        at point: CGPoint,
        in coordinateSpace: UICoordinateSpace) -> Bool {
        guard let header = (overlayViewController as? SearchViewController)?.header else {
            return false
        }
        let convertedPoint = coordinateSpace.convert(point, to: header)
        return header.bounds.contains(convertedPoint)
    }
}
