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
import os
import UniformTypeIdentifiers

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    static let blackoutAlpha: CGFloat = 0.1
    
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    var pageType: PageType = .spread
    var pageDirection: PageDirection = .left
    
    var documentPickerViewController: UIDocumentPickerViewController?

    #if targetEnvironment(macCatalyst)
    var selectStyleToolbar: NSToolbarItemGroup?
    var selectDirectionToolbar: NSToolbarItemGroup?
    #endif
    

    @objc func open(_ sender: Any) {
//        openPicker()
    }

    @objc func openAsANewWindow(_ sender: Any) {
        let userActivity = NSUserActivity(activityType: "com.sonson.multiwindow")
        userActivity.title = "aaaaaa"
        userActivity.addUserInfoEntries(from: ["string": "string2"])
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(open(_:)) {
            return true
        }
        if action == #selector(openAsANewWindow(_:)) {
            return true
        }
        return false
    }
    
    var currentScene: UIWindowScene? {
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
    
    var currentPageViewController: PageViewController? {
        return self.children.compactMap { (vc) -> PageViewController? in
            return vc as? PageViewController
        }.first
    }

    var currentThumbnailViewController: ThumbnailViewController? {
        return self.children.compactMap { (vc) -> ThumbnailViewController? in
            return vc as? ThumbnailViewController
        }.first
    }
    
    var needsOpenFilePicker = true
    
    var isOpenedAnyFile: Bool {
        return (currentPageViewController != nil)
    }
    
    func open(data: Data) {
        func open_(data: Data) {
            DispatchQueue.main.async {
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.isHidden = false
            }
            DispatchQueue.main.async {
                do {
                    let archiver = try Archiver(data: data)

                    if let currentPageViewController = self.currentPageViewController {
                        currentPageViewController.view.removeFromSuperview()
                        currentPageViewController.removeFromParent()
                    }
                    let vc = PageViewController(archiver: archiver, page: 0, pageDirection: self.pageDirection, pageType: self.pageType)
                    self.addChild(vc)
                    vc.view.frame = self.view.bounds
                    self.view.addSubview(vc.view)
                    vc.didMove(toParent: self)
                    
                } catch {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                }
            }
        }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        
        if let picker = documentPickerViewController {
            picker.dismiss(animated: true) {
                open_(data: data)
                self.documentPickerViewController = nil
            }
        } else {
            open_(data: data)
        }
        
    }
    
    func open(url: URL) {
        func open_(url: URL) {
            do {
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                if isDirectory.boolValue {
                    print(url.absoluteString)
                } else {
                    let archiver = try Archiver(url: url)
                    if let currentPageViewController = self.currentPageViewController {
                        currentPageViewController.view.removeFromSuperview()
                        currentPageViewController.removeFromParent()
                    }
                    let vc = PageViewController(archiver: archiver, page: 0, pageDirection: self.pageDirection, pageType: self.pageType)
                    self.addChild(vc)
                    vc.view.frame = self.view.bounds
                    self.view.addSubview(vc.view)
                    vc.didMove(toParent: self)
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        }
        
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        
        if let picker = documentPickerViewController {
            picker.dismiss(animated: true) {
                self.documentPickerViewController = nil
                open_(url: url)
            }
        } else {
            open_(url: url)
        }
    }
    
    func openPicker() {
        
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.view.bringSubviewToFront(self.activityIndicatorView)
        
        DispatchQueue.main.async {
            self.documentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.zip], asCopy: true)
            self.documentPickerViewController?.delegate = self
            if let picker = self.documentPickerViewController {
                self.present(picker, animated: true, completion: nil)
                if let vc = self.currentPageViewController {
                    UIView.animate(withDuration: 0.3) {
                        vc.view.alpha = BaseViewController.blackoutAlpha
                    }
                }
            }
        }
    }
    
    // MARK: - Thumbnail & Controller
    
    var isAnimatingControllerView = false
    
    var toolbarConstraint: NSLayoutConstraint?
    var toolbarHeightConstraint: NSLayoutConstraint?

    var toolView: UIView?
    
    var controllerViewHeight: CGFloat {
        if self.traitCollection.horizontalSizeClass == .regular {
            return ControllerView.regularHeight + self.view.safeAreaInsets.top
        } else {
            if self.view.bounds.size.width < self.view.bounds.size.height {
                return ControllerView.compactHeight + self.view.safeAreaInsets.top
            } else {
                return ControllerView.regularHeight + self.view.safeAreaInsets.top
            }
        }
    }
    
    #if targetEnvironment(macCatalyst)
    var titleBarHidden: Bool {
        get {
            if let windowScene = currentScene {
                return (windowScene.titlebar?.toolbar == nil)
            }
            return false
        }
        set {
//            if let windowScene = currentScene {
//                guard newValue != (windowScene.titlebar?.toolbar == nil) else { return }
//                if newValue {
//                    windowScene.titlebar?.toolbar = nil
//                } else {
//                    let toolbar = NSToolbar(identifier: "testToolbar")
//                    toolbar.delegate = self
//                    toolbar.allowsUserCustomization = false
//                    toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
//                    windowScene.titlebar?.toolbar = toolbar
//                    windowScene.titlebar?.titleVisibility = .hidden
//                }
//            }
        }
    }
    #endif
    
    func toggleToolbar() {
        
        guard !isAnimatingControllerView else { return }
        
        self.isAnimatingControllerView = true
        
        if let toolView = self.toolView {
            
            toolbarConstraint?.constant = -self.controllerViewHeight - self.view.safeAreaInsets.top
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (flag) in
                self.toolView = nil
                toolView.removeFromSuperview()
                self.isAnimatingControllerView = false
            }
        } else {
            
            let controllerView = ControllerView(frame: .zero)
            
            controllerView.pageDirection = pageDirection
            controllerView.pageType = pageType
            
            controllerView.pageDirectionSwitcher.addTarget(self, action: #selector(PageViewController.togglePageDirectionOnToolbar(_:)), for: .valueChanged)
            controllerView.pageTypeSwitcher.addTarget(self, action: #selector(PageViewController.togglePageTypeOnToolbar(_:)), for: .valueChanged)
            
//            controllerView.openButton.addTarget(self, action: #selector(PageViewController.open(_:)), for: .touchUpInside)
            
            controllerView.leftButton.addTarget(self, action: #selector(PageViewController.pageLeft(_:)), for: .touchUpInside)
            controllerView.rightButton.addTarget(self, action: #selector(PageViewController.pageRight(_:)), for: .touchUpInside)
            
            controllerView.translatesAutoresizingMaskIntoConstraints = false
            
            toolbarHeightConstraint = controllerView.heightAnchor.constraint(equalToConstant: self.controllerViewHeight)
            toolbarHeightConstraint?.isActive = true

            self.view.addSubview(controllerView)
            controllerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            controllerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            toolbarConstraint = controllerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -self.controllerViewHeight - self.view.safeAreaInsets.top)
            toolbarConstraint?.isActive = true
            
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                self.toolbarConstraint?.constant = -self.view.safeAreaInsets.top
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }) { (flag) in
                    self.toolView = controllerView
                    self.isAnimatingControllerView = false
                }
            }
        }
    }

}

// MARK: - UIViewController

extension BaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        os_log("[zipr] BaseViewController viewDidAppear", log: scribe, type: .error)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("[zipr] BaseViewController viewDidLoad", log: scribe, type: .error)
        
        self.view.backgroundColor = .systemGray
        
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        

        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)

        if self.needsOpenFilePicker {
            self.openPicker()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        toolbarHeightConstraint?.constant = controllerViewHeight
        toolbarConstraint?.constant = -self.view.safeAreaInsets.top

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (flag) in
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension BaseViewController: UIDocumentPickerDelegate {

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        self.documentPickerViewController = nil
        
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
        
        if let vc = currentPageViewController {
            UIView.animate(withDuration: 0.3) {
                vc.view.alpha = 1.0
            }
        }
        
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
        
        if let vc = currentThumbnailViewController {
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        if let view = self.toolView {
            view.removeFromSuperview()
            self.toolView = nil
        }
        
        DispatchQueue.main.async {
            if let url = urls.first {
                self.open(url: url)
            } else {
                if let vc = self.currentPageViewController {
                    UIView.animate(withDuration: 0.3) {
                        vc.view.alpha = 1.0
                    }
                }
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        }
    }
}

// MARK: - Drag and drop

extension BaseViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        let candidates = session.items.filter { (item) -> Bool in
            return item.itemProvider.hasItemConformingToTypeIdentifier("public.zip-archive") || item.itemProvider.hasItemConformingToTypeIdentifier("public.folder")
        }
        return (candidates.count > 0)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.items.forEach { (item) in
            print(item.itemProvider.registeredTypeIdentifiers)
            
            if item.itemProvider.canLoadObject(ofClass: URL.self) {
                print("-------canLoadObject------------")
            }
            if item.itemProvider.canLoadObject(ofClass: String.self) {
                print("-------canLoadObject------------")
            }
        }
        if session.hasItemsConforming(toTypeIdentifiers: ["public.zip-archive"]) {
            session.items.forEach { (item) in
                item.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.zip-archive") { (data, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.open(data: data)
                        }
                    }
                }
            }
        } else if session.hasItemsConforming(toTypeIdentifiers: ["public.folder"]) {
            session.items.forEach { (item) in
                print("-------------------")
                item.itemProvider.loadInPlaceFileRepresentation(forTypeIdentifier: "public.folder") { (url, success, error) in
                    if let url = url {
                        print(url)
                    }
                }
//                if item.itemProvider.canLoadObject(ofClass: NSURL.self) {
//                    print("-------canLoadObject------------")
//                }
//                item.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.folder") { (data, error) in
//                    if let data = data {
//                        print(data)
//                        if let str = String(data: data, encoding: .utf8) {
//                            print(str)
//                        }
//                    }
//                }
//                print(item.itemProvider.suggestedName)
//                item.itemProvider.registeredTypeIdentifiers.forEach { (str) in
//                    print(str)
//                }
            }
        }
    }
}
