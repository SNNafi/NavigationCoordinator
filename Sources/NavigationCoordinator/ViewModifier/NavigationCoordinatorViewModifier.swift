//
//  NavigationCoordinatorViewModifier.swift
//  
//
//  Created by Shahriar Nasim Nafi on 23/12/21.
//  Copyright © 2021 Shahriar Nasim Nafi. All rights reserved.
//

import SwiftUI
import Introspect

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct NavigationCoordinatorViewModifier: ViewModifier {
    var id: NavigationControllerId
    @Environment(\.navigationCoordinator) var navigationCoordinator
    public func body(content: Content) -> some View {
        content
            .introspectNavigationController { navgationController in
                NavigationCoordinator.navigationControllers[id] = navgationController
                NavigationCoordinator.navigationControllers[id]?.delegate = navigationCoordinator
                NavigationCoordinator.currentNavigationControllerId = id
                navigationCoordinator.onDismissForViewController[id] = [:]
            }
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension View {
    func navigationCoordinator(id: NavigationControllerId) -> some View {
        modifier(NavigationCoordinatorViewModifier(id: id))
    }
}
