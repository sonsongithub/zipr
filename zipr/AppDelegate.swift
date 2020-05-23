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
            builder.insertChild(AppDelegate.viewMenu(), atStartOfMenu: .view)
            builder.insertSibling(AppDelegate.openMenu(), afterMenu: .newScene)
        }
        
        super.buildMenu(with: builder)
        // TODO: build your menu
    }
    
    class func viewMenu() -> UIMenu {
        let commandPageRight = UIKeyCommand(title: NSLocalizedString("Page Right", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.commandPageRight(_:)),
                         input: UIKeyCommand.inputRightArrow,
                         modifierFlags: [],
                         propertyList: nil)
        let commnadPageLeft = UIKeyCommand(title: NSLocalizedString("Page Left", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.commnadPageLeft(_:)),
                         input: UIKeyCommand.inputLeftArrow,
                         modifierFlags: [],
                         propertyList: nil)
        
        let commandShiftPageRight = UIKeyCommand(title: NSLocalizedString("Shift One Page Right", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.commandShiftPageRight(_:)),
                         input: UIKeyCommand.inputRightArrow,
                         modifierFlags: .alternate,
                         propertyList: nil)
        
        let commandShiftPageLeft = UIKeyCommand(title: NSLocalizedString("Shift One Page Left", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.commandShiftPageLeft(_:)),
                         input: UIKeyCommand.inputLeftArrow,
                         modifierFlags: .alternate,
                         propertyList: nil)
        return UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.sonson.zipr.menus.viewMenu"),
                   options: .displayInline,
                   children: [commnadPageLeft, commandPageRight, commandShiftPageLeft, commandShiftPageRight])
    }
    
    class func openMenu() -> UIMenu {
        let openCommand =
            UIKeyCommand(title: NSLocalizedString("Open...", comment: ""),
                         image: nil,
                         action: #selector(BaseViewController.open(_:)),
                         input: "O",
                         modifierFlags: .command,
                         propertyList: nil)

        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.sonson.zipr.menus.openMenu"),
                   options: .displayInline,
                   children: [openCommand])
        return openMenu
    }
#endif
}
