//
//  Enviroment+Ex.swift
//  
//
//  Created by Shahriar Nasim Nafi on 23/12/21.
//  Copyright © 2021 Shahriar Nasim Nafi. All rights reserved.
//

import SwiftUI


public struct NavigationCoordinatorKey: EnvironmentKey {
    public static var defaultValue: NavigationCoordinator = NavigationCoordinator()
}

public extension EnvironmentValues {
    var navigationCoordinator: NavigationCoordinator {
        get { self[NavigationCoordinatorKey.self] }
        set { self[NavigationCoordinatorKey.self] = newValue }
    }
}
