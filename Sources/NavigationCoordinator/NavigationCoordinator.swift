//
//  NavigationController.swift
//
//
//  Created by Shahriar Nasim Nafi on 23/12/21.
//  Copyright © 2021 Shahriar Nasim Nafi. All rights reserved.
//


import SwiftUI
import UIKit
import Introspect

/// `NavigationCoordinator` acts as a controller for `NavigationView`. You can use `pushView`, `popView`, `popToView`, `popToRootView` as you can in traditional `UIKit`
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class NavigationCoordinator: NSObject {
    
    static var navigationControllers = [String: UINavigationController]()
    /// Current underlaying `UINavigationController` You need to update this to  `primaryNavigationController` after dismissing a sheet
    public static var currentNavigationControllerId: NavigationControllerId!
    var onDismissForViewController = [NavigationControllerId: [ViewId: NavigationItem]]()
    
    
    /// Pop current `View`
    /// - Parameters:
    ///   - id: Current underlaying `UINavigationController`. In general, you never need to set it directly
    ///   - animated: Set this value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
    public func popView(id: NavigationControllerId = currentNavigationControllerId, animated: Bool = true) {
        guard let navigationController = Self.navigationControllers[id] else { return }
        navigationController.popViewController(animated: animated)
    }
    
    /// Pop to any `View`
    /// - Parameters:
    ///   - id: Current underlaying `UINavigationController`. In general, you never need to set it directly
    ///   - viewId: The id of view that you want to be at the top of the stack. This view must currently be on the navigation stack.
    ///   - animated: Set this value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
    public func popToView(id: NavigationControllerId = currentNavigationControllerId, viewId: ViewId, animated: Bool = true) {
        guard let navigationController = Self.navigationControllers[id] else { return }
        if let viewController = navigationController.viewControllers.filter({ $0.accessibilityLabel == viewId}).first {
            navigationController.popToViewController(viewController, animated: animated)
        }
    }
    
    /// Push a `View`
    /// - Parameters:
    ///   - id: Current underlaying `UINavigationController`. In general, you never need to set it directly
    ///   - withViewId: The id of the view you want to push. Actually, it is a string. But you should use a static value for avioding any error
    ///   - onDismiss: Action perform on dismiss the view
    ///   - content: The  view you want to push
    ///   - animated: Set this value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
    public func pushView<Content: View>(id: NavigationControllerId = currentNavigationControllerId, withViewId: ViewId, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content, animated: Bool = true) {
        let viewController = UIHostingController(rootView: content())
        viewController.accessibilityLabel = withViewId
        let navigationItem = NavigationItem(viewController: viewController, onDismiss: onDismiss)
        onDismissForViewController[id]?[withViewId] = navigationItem
        guard let navigationController = Self.navigationControllers[id] else { return }
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    /// Pops all the view on the stack except the root view
    /// - Parameters:
    ///   - id: Current underlaying `UINavigationController`. In general, you never need to set it directly
    ///   - animated: Set this value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
    public func popToRootView(id: NavigationControllerId = currentNavigationControllerId, animated: Bool = true) {
        guard let navigationController = Self.navigationControllers[id] else { return }
        navigationController.popToRootViewController(animated: animated)
    }
    
}

// MARK: - OnDismiss
extension NavigationCoordinator: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool) {
            guard let dismissedViewController =
                    navigationController.transitionCoordinator?
                    .viewController(forKey: .from),
                  !navigationController.viewControllers
                    .contains(dismissedViewController) else {
                        return
                    }
            performOnDismissed(for: dismissedViewController.accessibilityLabel ?? "")
        }
    func performOnDismissed(for viewId: ViewId) {
        guard let dismissedViewController = onDismissForViewController[Self.currentNavigationControllerId]?[viewId] else {
            print("NOT FOUND")
            return
        }
        dismissedViewController.onDismiss?()
        print("Dismiss \(viewId)")
        onDismissForViewController[viewId] = nil
    }
}

