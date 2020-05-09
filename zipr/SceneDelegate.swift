//
//  SceneDelegate.swift
//  zippy
//
//  Created by sonson on 2020/05/03.
//  Copyright © 2020 sonson. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        print(scene.userActivity)
        return scene.userActivity
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        print("scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)")
        
        print(connectionOptions.userActivities)
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
            if let windowScene = scene as? UIWindowScene {
                if let titlebar = windowScene.titlebar {
                    let toolbar = NSToolbar(identifier: "testToolbar")
                    toolbar.delegate = self
                    toolbar.allowsUserCustomization = false
                    toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
                    titlebar.titleVisibility = .hidden

                    titlebar.toolbar = toolbar
                }
            }
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

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "testGroup")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "testGroup"), titles: ["Solver", "Resistance", "Settings"], selectionMode: .selectOne, labels: ["section1", "section2", "section3"], target: self, action: #selector(toolbarGroupSelectionChanged))
                
            group.setSelected(true, at: 0)
                
            return group
        }

        return nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier(rawValue: "testGroup")]
    }
        
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        print("testGroup selection changed to index: \(sender.selectedIndex)")
    }
}
#endif
