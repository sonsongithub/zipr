//
//  SceneDelegate.swift
//  zippy
//
//  Created by sonson on 2020/05/03.
//  Copyright © 2020 sonson. All rights reserved.
//

import UIKit
import os

let scribe = OSLog(subsystem: "com.mycompany.myapp", category: "myapp")

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func getDisplayingBaseViewControllers() -> [BaseViewController] {
        
        let squences_windows = UIApplication.shared.connectedScenes.compactMap { (scene) -> UIWindowScene? in
            return scene as? UIWindowScene
        }
        .map { (windowScene) -> [UIWindow] in
            return windowScene.windows
        }
        .joined()
        
        return Array(squences_windows).compactMap { (window) -> BaseViewController? in
            if let vc = window.rootViewController as? BaseViewController {
                if vc.picker != nil && !vc.isOpenedAnyFile() {
                    return vc
                }
            }
            return nil
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        os_log("[zipr] scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)", log: scribe, type: .default)
        
        guard let url = URLContexts.first?.url else {
            return
        }
        os_log("[zipr] url= %@", log: scribe, type: .default, url.absoluteString)
         
        do {
            #if targetEnvironment(macCatalyst)
                if let vc = getDisplayingBaseViewControllers().first {
                    vc.open(url: url)
                } else {
                    let act = NSUserActivity(activityType: "a")
                    act.userInfo = ["url": url.absoluteString]
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: act, options: nil, errorHandler: nil)
                }
            #else
                if !url.startAccessingSecurityScopedResource() {
                    throw NSError(domain: "com.sonson.zipr", code: 0, userInfo: nil)
                }
                let data = try Data.init(contentsOf: url)
                os_log("[zipr] url= %@", log: scribe, type: .default, data.count)

                url.stopAccessingSecurityScopedResource()
            
                let act = NSUserActivity(activityType: "a")
                act.userInfo = ["data": data]
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: act, options: nil, errorHandler: nil)
            #endif
        } catch {
            os_log("[zipr] url= %@", log: scribe, type: .error, error.localizedDescription)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        os_log("[zipr] scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)", log: scribe, type: .error)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let vc = BaseViewController(nibName: nil, bundle: nil)
        self.window?.rootViewController = vc

        if let data = connectionOptions.userActivities.first?.userInfo?["data"] as? Data {
            print(data.count)
            vc.needsOpenFilePicker = false
            vc.open(data: data)
        } else if let urlString = connectionOptions.userActivities.first?.userInfo?["url"] as? String {
            if let url = URL(string: urlString) {
                vc.needsOpenFilePicker = false
                vc.open(url: url)
            }
        } else if let urlContext = connectionOptions.urlContexts.first {
            os_log("[zipr] url = %@", log: scribe, type: .error, urlContext.url.absoluteString)
            vc.needsOpenFilePicker = false
            vc.open(url: urlContext.url)
        }
        
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
        
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
