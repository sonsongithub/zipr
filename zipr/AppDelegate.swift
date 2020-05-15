//
//  AppDelegate.swift
//  zippy
//
//  Created by sonson on 2020/05/03.
//  Copyright © 2020 sonson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print(sceneSessions.count)
    }

#if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        
        if builder.system == UIMenuSystem.main {
            builder.remove(menu: .format)
            builder.remove(menu: .edit)
            
            builder.insertChild(AppDelegate.openMenu(), atStartOfMenu: .file)
        }
        
        super.buildMenu(with: builder)
        // TODO: build your menu
    }
    
    class func openMenu() -> UIMenu {
        let openCommand =
            UIKeyCommand(title: NSLocalizedString("OpenTitle", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.newAction(_:)),
                         input: "O",
                         modifierFlags: .command,
                         propertyList: nil)
        
        let openNewWindowCommand =
            UIKeyCommand(title: NSLocalizedString("OpenTitle2", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.newAction2(_:)),
                         input: "O",
                         modifierFlags: [.command, .shift],
                         propertyList: nil)
        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.openMenu"),
                   options: .displayInline,
                   children: [openCommand, openNewWindowCommand])
        return openMenu
    }
#endif
}
