//
//  BaseViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/10.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit
import ZIPFoundation

class BaseViewController: UIViewController {
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView? = nil
    
    var page: Int = 0
    
    var pageType: PageType = .spread
    var pageDirection: PageDirection = .left

    #if targetEnvironment(macCatalyst)
    var selectStyleToolbar: NSToolbarItemGroup?
    var selectDirectionToolbar: NSToolbarItemGroup?
    #endif
    
    func getCurrentScene() -> UIWindowScene? {
        return UIApplication.shared.connectedScenes.compactMap { (scene) -> UIWindowScene? in
            return scene as? UIWindowScene
        }
        .first { (scene) -> Bool in
            let candidate = scene.windows.first { (window) -> Bool in
                return (window.rootViewController == self)
            }
            return (candidate != nil)
        }
    }

    #if targetEnvironment(macCatalyst)
    var titleBarHidden: Bool {
        get {
            if let windowScene = getCurrentScene() {
                return (windowScene.titlebar?.toolbar == nil)
            }
            return false
        }
        set {
            if let windowScene = getCurrentScene() {
                guard newValue != (windowScene.titlebar?.toolbar == nil) else { return }
                if newValue {
                    windowScene.titlebar?.toolbar = nil
                } else {
                    let toolbar = NSToolbar(identifier: "testToolbar")
                    toolbar.delegate = self
                    toolbar.allowsUserCustomization = false
                    toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
                    windowScene.titlebar?.toolbar = toolbar
                    windowScene.titlebar?.titleVisibility = .hidden
                }
            }
        }
    }
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        openPicker()
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(BaseViewController.tapped(_:)))
            
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            titleBarHidden = !titleBarHidden
        }
    }
    
    func toggleSpread() {
        pageType = .spread
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectStyleToolbar?.setSelected(true, at: 0)
        selectStyleToolbar?.setSelected(false, at: 1)
        #endif
    }
    
    func toggleSingle() {
        pageType = .single
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectStyleToolbar?.setSelected(false, at: 0)
        selectStyleToolbar?.setSelected(true, at: 1)
        #endif
    }
    
    func toggleToRight() {
        pageDirection = .right
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectDirectionToolbar?.setSelected(false, at: 0)
        selectDirectionToolbar?.setSelected(true, at: 1)
        #endif
    }
    
    func toggleToLeft() {
        pageDirection = .left
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectDirectionToolbar?.setSelected(true, at: 0)
        selectDirectionToolbar?.setSelected(false, at: 1)
        #endif
    }
    
    
    func openPicker() {
        
        self.activityIndicatorView?.isHidden = false
        self.activityIndicatorView?.startAnimating()

        DispatchQueue.main.async {
            let picker = UIDocumentPickerViewController.init(documentTypes: ["public.zip-archive"], in: .import)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func updatePageView() {
        if let child = self.children.first as? PageViewController {
            if let archiver = child.archiver {
                page = child.page
                child.view.removeFromSuperview()
                child.removeFromParent()

                let vc = PageViewController(archiver: archiver, page: page, pageDirection: pageDirection, pageType: pageType)
                self.addChild(vc)
                vc.view.frame = self.view.bounds
                self.view.addSubview(vc.view)
                vc.didMove(toParent: self)
            }
        }
    }
    
}

extension BaseViewController: UIDocumentPickerDelegate {

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            #if targetEnvironment(macCatalyst)
            
            if let vc = children.first as? PageViewController {
                if vc.archiver != nil {
                    return
                }
            }
            
            UIApplication.shared.connectedScenes.forEach { (scene) in
                if let uiscene = scene as? UIWindowScene {
                    uiscene.windows.forEach { (window) in
                        if window.rootViewController == self {
                            UIApplication.shared.requestSceneSessionDestruction(uiscene.session, options: .none) { (error) in
                                print(error)
                            }
                        }
                    }
                }
            }
            #endif
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                DispatchQueue.main.async {
                    do {
                        let archiver = try Archiver(url, identifier: "a")
    //                    self.archiver?.read(at: self.pageViewController.page)
                        
                        let userActivity = NSUserActivity(activityType: "reader")
                        userActivity.title = "Restore Item"
                        
                        let state: [String: URL] = ["URL": archiver.url]
                        userActivity.addUserInfoEntries(from: state)
                        
                        self.view.window?.windowScene?.userActivity = userActivity

                        if let child = self.children.first {
                            child.view.removeFromSuperview()
                            child.removeFromParent()

                        }
                        let vc = PageViewController(archiver: archiver, page: self.page, pageDirection: self.pageDirection, pageType: self.pageType)
                        self.addChild(vc)
                        vc.view.frame = self.view.bounds
                        self.view.addSubview(vc.view)
                        vc.didMove(toParent: self)
                        
                    } catch let error as NSError {
                        print(error)
                    } catch {
                        print("unknown error")
                    }
                    DispatchQueue.main.async {
                        self.activityIndicatorView?.stopAnimating()
                        self.activityIndicatorView?.isHidden = true
                    }
                }
            } else {
                self.activityIndicatorView?.stopAnimating()
                self.activityIndicatorView?.isHidden = true
            }
            
        }
}

#if targetEnvironment(macCatalyst)
extension BaseViewController {
    
    override func validate(_ command: UICommand) {
        if let dict = command.propertyList as? [String: String] {
            
            print(command)
            print(dict)
            
            if dict["PageType"] == "Single" {
                if pageType == .single {
                    command.state = .on
                } else {
                    command.state = .off
                }
            } else if dict["PageType"] == "Spread" {
                if pageType == .single {
                    command.state = .off
                } else {
                    command.state = .on
                }
            }
            if dict["PageDirection"] == "Left" {
                if pageDirection == .left {
                    command.state = .on
                } else {
                    command.state = .off
                }
            } else if dict["PageDirection"] == "Right" {
                if pageDirection == .left {
                    command.state = .off
                } else {
                    command.state = .on
                }
            }
        }
    }
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(open(_:)) {
            return true
        }
        if action == #selector(openAsANewWindow(_:)) {
            return true
        }
        if action == #selector(commnadPageLeft(_:)) {
            return true
        }
        if action == #selector(commandPageRight(_:)) {
            return true
        }
        if action == #selector(commandShiftPageLeft(_:)) {
            return true
        }
        if action == #selector(commandShiftPageRight(_:)) {
            return true
        }
        if action == #selector(commandSwitchToSingle(_:)) {
            return true
        }
        if action == #selector(commandSwitchToSpread(_:)) {
            return true
        }
        if action == #selector(commandSwitchToLeftDirection(_:)) {
            return true
        }
        if action == #selector(commandSwitchToRightDirection(_:)) {
            return true
        }
        return false
    }
    
    @objc func open(_ sender: UICommand) {
        openPicker()
    }
    @objc func openAsANewWindow(_ sender: UICommand) {
        let userActivity = NSUserActivity(
          activityType: "com.sonson.multiwindow"
        )
        
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
    
    @objc func commnadPageLeft(_ sender: UICommand) {
        if let vc = self.children.first as? PageViewController {
            vc.pageLeft()
        }
    }
    
    @objc func commandPageRight(_ sender: UICommand) {
        if let vc = self.children.first as? PageViewController {
            vc.pageRight()
        }
    }
    
    @objc func commandShiftPageLeft(_ sender: UICommand) {
        if let vc = self.children.first as? PageViewController {
            vc.shiftPageLeft()
        }
    }
    
    @objc func commandShiftPageRight(_ sender: UICommand) {
        if let vc = self.children.first as? PageViewController {
            vc.shiftPageRight()
        }
    }
    
    @objc func commandSwitchToSingle(_ sender: UICommand) {
        toggleSingle()
    }
    
    @objc func commandSwitchToSpread(_ sender: UICommand) {
        toggleSpread()
    }
    
    @objc func commandSwitchToLeftDirection(_ sender: UICommand) {
        toggleToLeft()
    }
    
    @objc func commandSwitchToRightDirection(_ sender: UICommand) {
        toggleToRight()
    }
}
#endif

#if targetEnvironment(macCatalyst)
extension BaseViewController: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "selectStyle")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "selectStyle"), titles: ["Spread", "Single"], selectionMode: .selectOne, labels: ["Spread", "Single"], target: self, action: #selector(BaseViewController.toolbarGroupSelectionChanged))
                
            group.setSelected(true, at: 0)
            
            selectStyleToolbar = group
                
            return group
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "space")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goRight"))
    //            item.image = UIImage(systemName: "photo")?.forNSToolbar()
            item.target = self
            item.label = "Add Image"
            item.title = "   "
            
            
            return item
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "selectDirection")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "selectDirection"), titles: ["Left", "Right"], selectionMode: .selectOne, labels: ["Left", "Right"], target: self, action: #selector(BaseViewController.toolbarGroupSelectionChanged_2))
                
            group.setSelected(true, at: 0)
            
            selectDirectionToolbar = group
                
            return group
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goLeft")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goLeft"))
//            item.image = UIImage(systemName: "photo")?.forNSToolbar()
            item.target = self
            item.action = #selector(didPushLeft)
            item.label = "Add Image"
            item.title = "L"
            item.isBordered = true
            
            return item
        }
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goRight")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goRight"))
//            item.image = UIImage(systemName: "photo")?.forNSToolbar()
            item.target = self
            item.action = #selector(didPushRight)
            item.label = "Add Image"
            item.title = "R"
            item.isBordered = true
            
            return item
        }
        return nil
    }
    
    @objc func didPushLeft(sender: NSToolbarItemGroup) {
        print("didPushLeft")
        if let vc = self.children.first as? PageViewController {
            vc.shiftPageLeft()
        }
    }
    
    @objc func didPushRight(sender: NSToolbarItemGroup) {
        print("didPushRight")
        if let vc = self.children.first as? PageViewController {
            vc.shiftPageRight()
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier(rawValue: "selectStyle"), NSToolbarItem.Identifier(rawValue: "selectDirection"), NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier(rawValue: "goLeft"), NSToolbarItem.Identifier(rawValue: "goRight")]
    }
        
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func toolbarGroupSelectionChanged_2(sender: NSToolbarItemGroup) {
        if sender.selectedIndex == 0 {
            pageDirection = .left
        } else if sender.selectedIndex == 1 {
            pageDirection = .right
        }
        updatePageView()
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        if sender.selectedIndex == 0 {
            pageType = .spread
        } else if sender.selectedIndex == 1 {
            pageType = .single
        }
        updatePageView()
    }
    
}
#endif
