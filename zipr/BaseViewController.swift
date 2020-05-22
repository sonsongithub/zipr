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

class BaseViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView? = nil
    
    var page: Int = 0
    
    var pageType: PageType = .spread
    var pageDirection: PageDirection = .left

    #if targetEnvironment(macCatalyst)
        var selectStyleToolbar: NSToolbarItemGroup?
        var selectDirectionToolbar: NSToolbarItemGroup?
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setViewController(flag: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setViewController(flag: true)
//        openPicker()
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

//    func setViewController(flag: Bool) {
//
////        if let archiver = self.archiver {
//            let vc = PageViewController(archiver: archiver, page: 0, pageDirection: .right, pageType: .spread)
//            self.addChild(vc)
//            vc.view.frame = self.view.bounds
//            self.view.addSubview(vc.view)
//            vc.didMove(toParent: self)
////        }
//    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        
//        guard let identifider = self.children.first?.userActivity?.persistentIdentifier else {
//            return
//        }
        
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
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(newAction(_:)) {
            return true
        }
        if action == #selector(newAction2(_:)) {
            return true
        }
        return false
    }
    
    @objc
    // User chose "New" sub menu command from the File menu (New Date or Text item).
    func newAction(_ sender: UICommand) {
        openPicker()
    }
    @objc
    // User chose "New" sub menu command from the File menu (New Date or Text item).
    func newAction2(_ sender: UICommand) {
        let userActivity = NSUserActivity(
          activityType: "com.sonson.multiwindow"
        )
        
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
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
//            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goLeft"), titles: ["L","a"], selectionMode: .momentary, labels: ["L","a"], target: self, action: #selector(BaseViewController.didPushLeft))
//            return group
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
            vc.pageToLeftByAPage()
        }
    }
    
    @objc func didPushRight(sender: NSToolbarItemGroup) {
        print("didPushRight")
        if let vc = self.children.first as? PageViewController {
            vc.pageToRightByAPage()
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier(rawValue: "selectStyle"), NSToolbarItem.Identifier(rawValue: "space"), NSToolbarItem.Identifier(rawValue: "selectDirection"), NSToolbarItem.Identifier.flexibleSpace, NSToolbarItem.Identifier(rawValue: "goLeft"), NSToolbarItem.Identifier(rawValue: "goRight")]
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
