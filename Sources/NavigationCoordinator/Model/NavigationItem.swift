//
//  NavigationItem.swift
//  
//
//  Created by Shahriar Nasim Nafi on 23/12/21.
//  Copyright © 2021 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

/// `NavigationItem` used for add viewcontroller to `UINavigationController` and  action for when pop that viewcontroller
struct NavigationItem {
    /// The `UIViewController`
    var viewController: UIViewController
    
    /// action on pop the viewController
    var onDismiss: (() -> Void)?
}
