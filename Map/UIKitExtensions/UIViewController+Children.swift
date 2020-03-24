//
//  UIViewController+Children.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 29/11/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    func addChild(_ child: UIViewController, in containerView: UIView) {
        guard containerView.isDescendant(of: view) else { return }
        addChild(child)
        containerView.addSubview(child.view)
        child.view.pinToSuperview()
        child.didMove(toParent: self)
    }

    func addChild(_ child: UIViewController, in containerView: UIView, at index: Int) {
        guard containerView.isDescendant(of: view) else { return }
        addChild(child)
        containerView.insertSubview(child.view, at: index)
        child.view.pinToSuperview()
        child.didMove(toParent: self)
    }

    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
