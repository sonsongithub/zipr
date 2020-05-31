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
    
    func macos_scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        os_log("[zipr] url= %@", log: scribe, type: .error, url.absoluteString)

        let windowCount = UIApplication.shared.connectedScenes.reduce(0) { (count, scene) -> Int in
            if let uiscene = scene as? UIWindowScene {
                return uiscene.windows.count + count
            } else {
                return count
            }
        }
        os_log("[zipr] windowCount = %d", log: scribe, type: .error, windowCount)

        let squences_windows = UIApplication.shared.connectedScenes.compactMap { (scene) -> UIWindowScene? in
            return scene as? UIWindowScene
        }
        .map { (windowScene) -> [UIWindow] in
            return windowScene.windows
        }
        .joined()
        
        let baseViewControllers = Array(squences_windows).compactMap { (window) -> BaseViewController? in
            if let vc = window.rootViewController as? BaseViewController {
                if vc.picker != nil && !vc.isOpenedAnyFile() {
                    return vc
                }
            }
            return nil
        }

        if let vc = baseViewControllers.first {
            vc.open(url: url)
        } else {
            let act = NSUserActivity(activityType: "a")
            act.userInfo = ["url": url.absoluteString]
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: act, options: nil, errorHandler: nil)
        }
    }
    
    func ios_scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        os_log("[zipr] url= %@", log: scribe, type: .error, url.absoluteString)
        let act = NSUserActivity(activityType: "a")
        act.userInfo = ["url": url.absoluteString]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: act, options: nil, errorHandler: nil)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("[zipr] scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)")
        os_log("[zipr] scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)", log: scribe, type: .error)
        
        #if targetEnvironment(macCatalyst)
            macos_scene(scene, openURLContexts: URLContexts)
        #else
            ios_scene(scene, openURLContexts: URLContexts)
        #endif
    }
    
    func macos_scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let vc = BaseViewController(nibName: nil, bundle: nil)
        self.window?.rootViewController = vc
        
        if let urlString = connectionOptions.userActivities.first?.userInfo?["url"] as? String {
            if let url = URL(string: urlString) {
                print(url)
                vc.needsOpenFilePicker = false
                vc.open(url: url)
            }
        }
        
        if let urlContext = connectionOptions.urlContexts.first {
            os_log("[zipr] url = %@", log: scribe, type: .error, urlContext.url.absoluteString)
            vc.needsOpenFilePicker = false
            vc.open(url: urlContext.url)
        }
        
        self.window?.makeKeyAndVisible()
        
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
    }
    
    func ios_scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let vc = BaseViewController(nibName: nil, bundle: nil)
        
        if let urlString = connectionOptions.userActivities.first?.userInfo?["url"] as? String {
            if let url = URL(string: urlString) {
                print(url)
                vc.needsOpenFilePicker = false
                vc.open(url: url)
            }
        }
        
        if let urlContext = connectionOptions.urlContexts.first {
            os_log("[zipr] url = %@", log: scribe, type: .error, urlContext.url.absoluteString)
            vc.needsOpenFilePicker = false
            vc.open(url: urlContext.url)
        }
        
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("[zipr] scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)")
        os_log("[zipr] scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)", log: scribe, type: .error)
        #if targetEnvironment(macCatalyst)
            macos_scene(scene, willConnectTo: session, options: connectionOptions)
        #else
            ios_scene(scene, willConnectTo: session, options: connectionOptions)
        #endif
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
