//
//  AppDelegate.swift
//  zippy
//
//  Created by sonson on 2020/05/03.
//  Copyright © 2020 sonson. All rights reserved.
//

import UIKit
import os

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        os_log("[zipr] %@ %@", log: scribe, type: .error, String(describing: self), #function)
        Archiver.deleteOldCacheFiles()
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print(#function)
        print(sceneSessions.count)
    }

    
    override func buildMenu(with builder: UIMenuBuilder) {
        
        if builder.system == UIMenuSystem.main {
            builder.remove(menu: .format)
            builder.remove(menu: .edit)
            builder.insertChild(AppDelegate.pagingMenu, atStartOfMenu: .view)
            builder.insertChild(AppDelegate.toggleMenu, atStartOfMenu: .view)
            builder.insertSibling(AppDelegate.openMenu, afterMenu: .newScene)
        }
        
        super.buildMenu(with: builder)
    }
    
    @objc func openFolder(_ sender: Any) {
        let userActivity = NSUserActivity(activityType: "com.sonson.multiwindow")
        userActivity.title = "aaaaaa"
        userActivity.addUserInfoEntries(from: ["folder": true])
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
    
    class var openCommands: [UIKeyCommand] {
        return [
            UIKeyCommand(title: "Open...",
                image: nil,
                action: #selector(BaseViewController.open(_:)),
                input: "O",
                modifierFlags: [.command],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Open...",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Open folder...",
                image: nil,
                action: #selector(AppDelegate.openFolder(_:)),
                input: "F",
                modifierFlags: [.command],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Open folder...",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Open as New Window",
                image: nil,
                action: #selector(BaseViewController.openAsANewWindow(_:)),
                input: "O",
                modifierFlags: [.command, .shift],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Open as New Window",
                attributes: [],
                state: .off),
        ]
    }
    
    class var pagingCommands: [UIKeyCommand] {
        #if targetEnvironment(macCatalyst)
        let pageForwardInput = "N"
        #else
        let pageForwardInput = " "
        #endif
        
        return [
            UIKeyCommand(title: "Page Left",
                image: nil,
                action: #selector(PageViewController.pageLeft(_:)),
                input: UIKeyCommand.inputLeftArrow,
                modifierFlags: [],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Page Left",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Page Right",
                image: nil,
                action: #selector(PageViewController.pageRight(_:)),
                input: UIKeyCommand.inputRightArrow,
                modifierFlags: [],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Page Right",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Shift Page Left",
                image: nil,
                action: #selector(PageViewController.shiftPageLeft(_:)),
                input: UIKeyCommand.inputLeftArrow,
                modifierFlags: [.alternate],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Shift Page Left",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Shift Page Right",
                image: nil,
                action: #selector(PageViewController.shiftPageRight(_:)),
                input: UIKeyCommand.inputRightArrow,
                modifierFlags: [.alternate],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Shift Page Right",
                attributes: [],
                state: .off),
            UIKeyCommand(title: "Page Forward",
                image: nil,
                action: #selector(PageViewController.pageForward(_:)),
                input: pageForwardInput,
                modifierFlags: [],
                propertyList: nil,
                alternates: [],
                discoverabilityTitle: "Page Forward",
                attributes: [],
                state: .off)
        ]
    }
    
    class var toggleCommands: [UIKeyCommand] {
        return [
                UIKeyCommand(title: NSLocalizedString("Single", comment: ""),
                     image: nil,
                     action: #selector(PageViewController.toggleToSingle(_:)),
                     input: "S",
                     modifierFlags: [.command],
                     propertyList: ["PageType": "Single"]),
                UIKeyCommand(title: NSLocalizedString("Spread", comment: ""),
                    image: nil,
                    action: #selector(PageViewController.toggleToSpread(_:)),
                    input: "P",
                    modifierFlags: [.command],
                    propertyList: ["PageType": "Spread"]),
                UIKeyCommand(title: NSLocalizedString("To Left Direction", comment: ""),
                    image: nil,
                    action: #selector(PageViewController.toggleToLeft(_:)),
                    input: UIKeyCommand.inputLeftArrow,
                    modifierFlags: [.command],
                    propertyList: ["PageDirection": "Left"]),
                UIKeyCommand(title: NSLocalizedString("To Right Direction", comment: ""),
                    image: nil,
                    action: #selector(PageViewController.toggleToRight(_:)),
                    input: UIKeyCommand.inputRightArrow,
                    modifierFlags: [.command],
                    propertyList: ["PageDirection": "Right"])
        ]
    }
    
    class var toggleMenu: UIMenu {
        return UIMenu(title: "",
                image: nil,
                identifier: UIMenu.Identifier("com.sonson.zipr.menus.toggleMenu"),
                options: .displayInline,
                children: self.toggleCommands)
    }
    
    class var pagingMenu: UIMenu {
        return UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.sonson.zipr.menus.pagingMenu"),
                   options: .displayInline,
                   children: self.pagingCommands)
    }
    
    class var openMenu: UIMenu {
        return UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.sonson.zipr.menus.openMenu"),
                   options: .displayInline,
                   children: self.openCommands)
    }
}
