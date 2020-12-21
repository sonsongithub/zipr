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
    
    func updatePageView() {

        if let currentPageViewController = currentPageViewController {
            
            if let archiver = currentPageViewController.archiver {
                let page = currentPageViewController.page
                currentPageViewController.view.removeFromSuperview()
                currentPageViewController.removeFromParent()

                let vc = PageViewController(archiver: archiver, page: page, pageDirection: pageDirection, pageType: pageType)
                self.addChild(vc)
                vc.view.frame = self.view.bounds
                self.view.addSubview(vc.view)
                vc.didMove(toParent: self)
                
                self.view.sendSubviewToBack(vc.view)
            }
        }
    }

    // MARK: - Thumbnail & Controller
    
    var isAnimatingControllerView = false
    
    var isAnimatingThumbnailView = false
    
    var constraint: NSLayoutConstraint?
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
            if let windowScene = currentScene {
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
            
            controllerView.pageDirectionSwitcher.addTarget(self, action: #selector(BaseViewController.togglePageDirectionOnToolbar(_:)), for: .valueChanged)
            controllerView.pageTypeSwitcher.addTarget(self, action: #selector(BaseViewController.togglePageTypeOnToolbar(_:)), for: .valueChanged)
            
            controllerView.openButton.addTarget(self, action: #selector(BaseViewController.open(_:)), for: .touchUpInside)
            
            controllerView.leftButton.addTarget(self, action: #selector(BaseViewController.pageLeft(_:)), for: .touchUpInside)
            controllerView.rightButton.addTarget(self, action: #selector(BaseViewController.pageRight(_:)), for: .touchUpInside)
            
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

    func toggleThumbnails() {
    
        
        #if targetEnvironment(macCatalyst)
        guard !isAnimatingThumbnailView else { return }
        titleBarHidden = !titleBarHidden
        #else
        guard !isAnimatingControllerView && !isAnimatingThumbnailView else { return }
        toggleToolbar()
        #endif
        
        guard !isAnimatingThumbnailView else { return }
        
        isAnimatingThumbnailView = true
        
        if let vc = currentThumbnailViewController {
            if let constraint = self.constraint {
                constraint.constant = 240
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (flag) in
                vc.view.removeFromSuperview()
                vc.removeFromParent()
                self.constraint = nil
                self.isAnimatingThumbnailView = false
            }
        } else {
            
            if let vc = currentPageViewController {
                
                var page = 0
                if let vc = currentPageViewController {
                    page = vc.page
                }

                let thumbnailViewController = ThumbnailViewController(archiver: vc.archiver, pageDirection: pageDirection, startAt: page)
                
                thumbnailViewController.view.translatesAutoresizingMaskIntoConstraints = false

                self.view.addSubview(thumbnailViewController.view)
                self.addChild(thumbnailViewController)
                thumbnailViewController.didMove(toParent: self)
                
                thumbnailViewController.view.heightAnchor.constraint(equalToConstant: 240).isActive = true
                thumbnailViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                thumbnailViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
                constraint = thumbnailViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 240)
                constraint?.isActive = true

                
                self.view.layoutIfNeeded()
                DispatchQueue.main.async {
                    self.constraint?.constant = 0
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    }) { (flag) in
                        self.isAnimatingThumbnailView = false
                    }
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
                
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(BaseViewController.tapped(_:)))
        
        self.view.addSubview(activityIndicatorView)
        
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
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

// MARK: - UIGestureRecongnizer

extension BaseViewController {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.currentPageViewController == nil {
            return false
        }
        if let v = touch.view {
            if let vc = currentThumbnailViewController {
                if v.isDescendant(of: vc.view) {
                    return false
                }
            }
            if let toolView = self.toolView {
                if v.isDescendant(of: toolView) {
                    return false
                }
            }
        }
        return true
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        os_log("[zipr] tapped", log: scribe, type: .error)
        
        if sender.state == .ended {
            
            
            let tap = sender.location(in: self.view)
            
            let tapAreaWidthRatio = CGFloat(0.2)
            let tapAreaHeightRatio = CGFloat(0.9)
            
            let leftArea = CGRect(x: 0, y: self.view.bounds.height * (1 - tapAreaHeightRatio) * 0.5, width: self.view.bounds.width * tapAreaWidthRatio, height: self.view.bounds.height * tapAreaHeightRatio)
            let rightArea = CGRect(x: self.view.bounds.width * (1 - tapAreaWidthRatio), y: self.view.bounds.height * (1 - tapAreaHeightRatio) * 0.5, width: self.view.bounds.width * tapAreaWidthRatio, height: self.view.bounds.height * tapAreaHeightRatio)
            
            if leftArea.contains(tap) {
                if let currentPageViewController = self.currentPageViewController {
                    currentPageViewController.pageLeft()
                }
            } else if rightArea.contains(tap) {
                if let currentPageViewController = self.currentPageViewController {
                    currentPageViewController.pageRight()
                }
            } else {
                let rect = self.view.bounds.inset(by: self.view.safeAreaInsets)
                if rect.contains(tap) {
                    toggleThumbnails()
                }
            }
            
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

// MARK: - UIKeyCommand for

extension BaseViewController {

    #if targetEnvironment(macCatalyst)
    #else
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return AppDelegate.openCommands + AppDelegate.toggleCommands + AppDelegate.pagingCommands
    }
    #endif

    override func validate(_ command: UICommand) {
        if let dict = command.propertyList as? [String: String] {
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
        if action == #selector(pageLeft(_:)) {
            return true
        }
        if action == #selector(pageRight(_:)) {
            return true
        }
        if action == #selector(pageForward(_:)) {
            return true
        }
        if action == #selector(shiftPageLeft(_:)) {
            return true
        }
        if action == #selector(shiftPageRight(_:)) {
            return true
        }
        if action == #selector(toggleToSpread(_:)) {
            return true
        }
        if action == #selector(toggleToSpread(_:)) {
            return true
        }
        if action == #selector(toggleToLeft(_:)) {
            return true
        }
        if action == #selector(toggleToRight(_:)) {
            return true
        }
        return false
    }
}

// MARK: - Toolbar for Mac Catalyst

#if targetEnvironment(macCatalyst)
extension BaseViewController: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "selectStyle")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "selectStyle"), images: [UIImage(named: "book")!, UIImage(named: "single")!], selectionMode: .selectOne, labels: ["Spread", "Single"], target: self, action: #selector(BaseViewController.togglePageTypeOnToolbar))
            group.setSelected(true, at: 0)
            selectStyleToolbar = group
            return group
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "selectDirection")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "selectDirection"),
                                                images: [UIImage(named: "left_direction")!, UIImage(named: "right_direction")!],
                                                selectionMode: .selectOne,
                                                labels: ["Left", "Right"],
                                                target: self,
                                                action: #selector(BaseViewController.togglePageDirectionOnToolbar))
            group.setSelected(true, at: 0)
            selectDirectionToolbar = group
            return group
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goLeft")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goLeft"))
            item.image = UIImage(systemName: "arrow.left")
            item.target = self
            item.action = #selector(shiftPageLeft(_:))
            item.isBordered = true
            return item
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goRight")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goRight"))
            item.image = UIImage(systemName: "arrow.right")
            item.target = self
            item.action = #selector(shiftPageRight(_:))
            item.isBordered = true
            return item
        }
        return nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            NSToolbarItem.Identifier.flexibleSpace,
            NSToolbarItem.Identifier(rawValue: "selectStyle"),
            NSToolbarItem.Identifier(rawValue: "selectDirection"),
            NSToolbarItem.Identifier.flexibleSpace,
            NSToolbarItem.Identifier(rawValue: "goLeft"),
            NSToolbarItem.Identifier(rawValue: "goRight")
        ]
    }
        
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}
#endif

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

// MARK: - Methods for control

extension BaseViewController {
    
    @objc func pageLeft(_ sender: Any) {
        if let currentPageViewController = self.currentPageViewController {
            currentPageViewController.pageLeft()
        }
    }
    
    @objc func pageRight(_ sender: Any) {
        if let currentPageViewController = self.currentPageViewController {
            currentPageViewController.pageRight()
        }
    }
    
    @objc func shiftPageLeft(_ sender: Any) {
        if let currentPageViewController = self.currentPageViewController {
            currentPageViewController.shiftPageLeft()
        }
    }
    
    @objc func shiftPageRight(_ sender: Any) {
        if let currentPageViewController = self.currentPageViewController {
            currentPageViewController.shiftPageRight()
        }
    }
    
    @objc func pageForward(_ sender: Any) {
        if let currentPageViewController = self.currentPageViewController {
            currentPageViewController.pageForward()
        }
    }
    
    @objc func toggleToSingle(_ sender: Any) {
        pageType = .single
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectStyleToolbar?.setSelected(false, at: 0)
        selectStyleToolbar?.setSelected(true, at: 1)
        #endif
    }
    
    @objc func toggleToSpread(_ sender: Any) {
        pageType = .spread
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectStyleToolbar?.setSelected(true, at: 0)
        selectStyleToolbar?.setSelected(false, at: 1)
        #endif
    }
    
    @objc func toggleToRight(_ sender: Any) {
        pageDirection = .right
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectDirectionToolbar?.setSelected(false, at: 0)
        selectDirectionToolbar?.setSelected(true, at: 1)
        #endif
        if let vc = currentThumbnailViewController {
            vc.pageDirection = .right
        }
    }
    
    @objc func toggleToLeft(_ sender: Any) {
        pageDirection = .left
        updatePageView()
        #if targetEnvironment(macCatalyst)
        selectDirectionToolbar?.setSelected(true, at: 0)
        selectDirectionToolbar?.setSelected(false, at: 1)
        #endif
        if let vc = currentThumbnailViewController {
            vc.pageDirection = .left
        }
    }

    @objc func open(_ sender: Any) {
        openPicker()
    }

    @objc func openAsANewWindow(_ sender: Any) {
        let userActivity = NSUserActivity(
          activityType: "com.sonson.multiwindow"
        )
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
    
    @objc func togglePageTypeOnToolbar(_ sender: Any) {
        let selectedIndex: Int? = {
            #if targetEnvironment(macCatalyst)
            if let obj = sender as? NSToolbarItemGroup {
                return obj.selectedIndex
            }
            #else
            if let obj = sender as? UISegmentedControl {
                return obj.selectedSegmentIndex
            }
            #endif
            return nil
        }();
        
        if let selectedIndex = selectedIndex {
            
            if selectedIndex == 0 {
                pageType = .spread
            } else if selectedIndex == 1 {
                pageType = .single
            }
            updatePageView()
        }
    }
    
    @objc func togglePageDirectionOnToolbar(_ sender: Any) {
        
        let selectedIndex: Int? = {
            #if targetEnvironment(macCatalyst)
            if let obj = sender as? NSToolbarItemGroup {
                return obj.selectedIndex
            }
            #else
            if let obj = sender as? UISegmentedControl {
                return obj.selectedSegmentIndex
            }
            #endif
            return nil
        }();
        
        if let selectedIndex = selectedIndex {
            if selectedIndex == 0 {
                pageDirection = .left
            } else if selectedIndex == 1 {
                pageDirection = .right
            }
            updatePageView()

            if let vc = currentThumbnailViewController {
                vc.pageDirection = pageDirection
            }
        }
    }

}
