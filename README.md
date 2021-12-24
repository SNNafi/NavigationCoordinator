# NavigationCoordinator

<p align="center">

<img src="https://img.shields.io/badge/iOS-13.0-orange" alt="iOS: 13.0">

<img src="https://img.shields.io/badge/Swift-5.5-orange" alt="Swift: 5.5">
    <a href="./LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
    </a>
<img src="https://img.shields.io/badge/Version-0.0.1-yellow" alt="Version: 0.0.1">

</p>

NavigationCoordinator acts as a coordinator for `NavigationView`. You can use `pushView`, `popView`, `popToView`, `popToRootView` in `SwiftUI` as you can in traditional `UIKit`

# Installing

## Swift Package Manager
You can install it using SPM

```console
https://github.com/SNNafi/NavigationCoordinator.git
```
# Usage

Suppose, you want to programmatically push a view or pop a view or pop to any specific view or pop to root view. There is no way to do this in SwiftUI. NavigationCoordinator is the best in this situation. It does not include any extra or unnecessary dependency, at the same time, it works with `UINavigationController` as `NavigationView` does. Better say, it adds extra functionalities for `NavigationView` with the help of battle tested `UINavigationController`. 

It supports working with multiple `UINavigationController`. Suppose, when you will present a modal, you will need another `UINavigationController` for this to manage navigation between views that is independent from the view presenting it. So, you need two `UINavigationController`. And this package has build in supports for that. But there is a little work needed from your side. Let's get started

First create an extension in `NavigationControllerId`

```swift
extension NavigationControllerId {
    // for any other navigation controller, just declare a `NavigationControllerId` for this to uniquely identify.
    // There is already `primaryNavigationController` for default navigation controller
    static let sheetNavigationController = "SheetNavigationController"
}
```

Suppose you have 5 view, `HomeView`,  `ListView`,  `DetailView`, `SettingView`,  `AboutView`,  `ContactView`,  `PrivacyView`. Create an extension for them to uniquely identify them, so that we can pop to any view directly !

```swift
extension ViewId {
    static let homeView = "homeView"
    static let listView = "listView"
    static let detailView = "detailView"
    static let settingView = "settingView"
    static let aboutView = "aboutView"
    static let contactView = "contactView"
    static let privacyView = "privacyView"
}
```

You are ready to go

```swift

import SwiftUI
import NavigationCoordinator

struct ContentView: View {
    
    @Environment(\.navigationCoordinator) var navigationCoordinator
    
    var body: some View {
        NavigationView { // wrap in NavigationView
            VStack {
                Text("Hello, NavigationCoordinator Example!")
                    .padding()
                
                Button {
                    // push to HomeView
                    navigationCoordinator.pushView(withViewId: .homeView) {
                        HomeView()
                    }
                } label: {
                    Text("HomeView")
                }.padding()
            }
            .onAppear {
              
            }
            .navigationCoordinator(id: .primaryNavigationController) // initiate default navigation controller, do not call this again unless you need another navigation controller for modal
        }
    }
}

```

Suppose now by pushing, now you are in `PrivacyView`. That is like  `HomeView` -> `SettingView` -> `AboutView` -> `ContactView` -> `PrivacyView`

Now you want to directly return to `SettingView`

```swift

import SwiftUI

struct SheetSixthView: View {
    
    @Environment(\.navigationCoordinator) var navigationCoordinator
  
    var body: some View {
        VStack {
            Text(String.currentFileName())
                .padding()
                .onTapGesture {
                    navigationCoordinator.popToView(viewId: .settingView) // this will do the rest for you
                }
        }
    }
}

```

What if you want to directly return to `HomeView`

```swift

import SwiftUI

struct SheetSixthView: View {
    
    @Environment(\.navigationCoordinator) var navigationCoordinator
  
    var body: some View {
        VStack {
            Text(String.currentFileName())
                .padding()
                .onTapGesture {
                    navigationCoordinator.popToRootView() // you are good to go
                }
        }
    }
}

```

Or, you just want to return to the previous view ?

```swift

import SwiftUI

struct SheetSixthView: View {
    
    @Environment(\.navigationCoordinator) var navigationCoordinator
  
    var body: some View {
        VStack {
            Text(String.currentFileName())
                .padding()
                .onTapGesture {
                     navigationCoordinator.popView() // are you still here ?
                }
        }
    }
}

```

And you need state based navigation ? `NavigationLink` is still here to rescue. As said, this package just coordinates, doesn't take way any exisiting feature.

What about modal ? Suppose you need to use another navigation controller. 

```swift
import SwiftUI
import NavigationCoordinator

struct ModalView: View {
    
    @Environment(\.navigationCoordinator) var navigationCoordinator
    
    var body: some View {
        NavigationView { // wrap in NavigationView
            VStack {
                Text("Hello, NavigationCoordinator Example!")
                    .padding()
                
                Button {
                    // push to SomeView
                    navigationCoordinator.pushView(withViewId: .someView) {
                        SomeView()
                    }
                } label: {
                    Text("SomeView")
                }.padding()
            }
             .navigationCoordinator(id: .sheetNavigationController) // initiate another navigation controller
        }
    }
}

```
__Important:__ When presenting this using sheet, need to set `id` back to the `.primaryNavigationController` in `onDismiss` . Like that, 

```swift
 .sheet(isPresented: $isShow, onDismiss: { NavigationCoordinator.currentNavigationControllerId = .primaryNavigationController }, content: {
            ModalView()
        })
```
And, the rest thing as you do in previous steps.

## Inject NavigationCoordinator 

By default you can programmatically push and pop only inside the `NavigationView` hierarchy (by accessing the `NavigationCoordinator` environment). But you can do it from outside also

__But there are few things you need to keep in mind__

No matter what, you always need to __initiate a navigation controller__ by using this `.navigationCoordinator(id:)` in view hierarchy. But it must need to perform in a view which is wrapped into a `NavigationView`

Like, 

```swift

 NavigationView {
     SomeView()
         .navigationCoordinator(id: .primaryNavigationController) // this is a must. Otherwise, cannot track down the underlying UINavigationController
 }

```
Then you can do, 

```swift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static let navigationCoordinator = NavigationCoordinator()

    .....
    .....
    let mainView = MainView()
        .environment(\.navigationCoordinator, Self.navigationCoordinator) // this is not necessary. But if you need, you can set it to use from another non view type like view model or router


   // Use a UIHostingController as window root view controller.
      if let windowScene = scene as? UIWindowScene {
          let window = UIWindow(windowScene: windowScene)
          window.rootViewController = UIHostingController(rootView: mainView)
          self.window = window
          window.makeKeyAndVisible()
      }
    .....
    .....
}


struct ContentView: View {

    var body: some View {
        NavigationView {
            HomeView(router: DefaultRouter())
                .navigationCoordinator(id: .primaryNavigationController)
        }
    }
}

class DefaultRouter {
    
    func navigateToList() {
        SceneDelegate.navigationCoordinator.pushView(withViewId: .fourthView) {
            FourthView()
        }
    }

    func navigateToDetail() {
        SceneDelegate.navigationCoordinator.pushView(withViewId: .fifthView) {
            FifthView()
        }
    }
}

struct HomeView: View {

    let router: DefaultRouter

    var body: some View {
        VStack {
            Text("HomeView")
            Button("ListView") {
                router.navigateToList()
            }
            Button("DetailView") {
                router.navigateToDetail()
            }
        }
    }
}
```

# Status

This is an active project. I will try to add new features.
