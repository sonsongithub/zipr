//
//  PageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/15.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import os
import UIKit

enum PageDirection {
    case left
    case right
}

enum PageType {
    case single
    case spread
}

class PageViewController: UIPageViewController, UIGestureRecognizerDelegate {
    
    #if targetEnvironment(macCatalyst)
    var selectStyleToolbar: NSToolbarItemGroup?
    var selectDirectionToolbar: NSToolbarItemGroup?
    #endif
    
    let archiver: Archiver!
    
    let pageDirection :PageDirection
    let pageType: PageType
    
    var page: Int = 0
    
    var count: Int = 11
    var paging = false

    required init?(coder: NSCoder) {
        self.pageDirection = .left
        self.pageType = .single
        self.archiver = nil
        super.init(coder: coder)
        fatalError("Can not create this view controller with NSCoder")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let windowScene = currentScene {
            let toolbar = NSToolbar(identifier: "testToolbar")
            toolbar.delegate = self
            toolbar.allowsUserCustomization = false
            toolbar.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "testGroup")
            windowScene.titlebar?.toolbar = toolbar
            windowScene.titlebar?.titleVisibility = .hidden
        }
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(PageViewController.tapped(_:))
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }

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
    
    
    @objc func pageLeft(_ sender: Any) {
        pageLeft()
    }
    
    @objc func pageRight(_ sender: Any) {
        pageRight()
    }
    
    @objc func shiftPageLeft(_ sender: Any) {
        shiftPageLeft()
    }
    
    @objc func shiftPageRight(_ sender: Any) {
        shiftPageRight()
    }
    
    @objc func pageForward(_ sender: Any) {
        pageForward()
    }
    
    @objc func toggleToSingle(_ sender: Any) {
        if let archiver = self.archiver {
            let page = self.page
            
            let par = self.parent!
            
            self.view.removeFromSuperview()
            self.removeFromParent()

            let vc = PageViewController(archiver: archiver, page: page, pageDirection: pageDirection, pageType: .single)
            par.addChild(vc)
            vc.view.frame = par.view.bounds
            par.view.addSubview(vc.view)
            vc.didMove(toParent: par)
            
            par.view.sendSubviewToBack(vc.view)
        }
        
//        pageType = .single
//        updatePageView()
//        #if targetEnvironment(macCatalyst)
//        selectStyleToolbar?.setSelected(false, at: 0)
//        selectStyleToolbar?.setSelected(true, at: 1)
//        #endif
    }
    
    @objc func toggleToSpread(_ sender: Any) {
        if let archiver = self.archiver {
            let page = self.page
            
            let par = self.parent!
            
            self.view.removeFromSuperview()
            self.removeFromParent()

            let vc = PageViewController(archiver: archiver, page: page, pageDirection: pageDirection, pageType: .spread)
            par.addChild(vc)
            vc.view.frame = par.view.bounds
            par.view.addSubview(vc.view)
            vc.didMove(toParent: par)
            
            par.view.sendSubviewToBack(vc.view)
        }
        
//        pageType = .spread
//        updatePageView()
//        #if targetEnvironment(macCatalyst)
//        selectStyleToolbar?.setSelected(true, at: 0)
//        selectStyleToolbar?.setSelected(false, at: 1)
//        #endif
    }
    
    @objc func toggleToRight(_ sender: Any) {
//        pageDirection = .right
//        updatePageView()
//        #if targetEnvironment(macCatalyst)
//        selectDirectionToolbar?.setSelected(false, at: 0)
//        selectDirectionToolbar?.setSelected(true, at: 1)
//        #endif
//        if let vc = currentThumbnailViewController {
//            vc.pageDirection = .right
//        }
    }
    
    @objc func toggleToLeft(_ sender: Any) {
//        pageDirection = .left
//        updatePageView()
//        #if targetEnvironment(macCatalyst)
//        selectDirectionToolbar?.setSelected(true, at: 0)
//        selectDirectionToolbar?.setSelected(false, at: 1)
//        #endif
//        if let vc = currentThumbnailViewController {
//            vc.pageDirection = .left
//        }
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
//
//            if selectedIndex == 0 {
//                pageType = .spread
//            } else if selectedIndex == 1 {
//                pageType = .single
//            }
//            updatePageView()
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
//            if selectedIndex == 0 {
//                pageDirection = .left
//            } else if selectedIndex == 1 {
//                pageDirection = .right
//            }
//            updatePageView()
//
//            if let vc = currentThumbnailViewController {
//                vc.pageDirection = pageDirection
//            }
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(open(_:)) {
//            return true
//        }
//        if action == #selector(openAsANewWindow(_:)) {
//            return true
//        }
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
        if action == #selector(toggleToSingle(_:)) {
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
    
    func viewControllerForPageLeft(pageType: PageType, pageDirection: PageDirection, page: Int) -> (UIViewController, Int)? {
        
        var nextPage = 0

        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page + 2 < count else { return nil }
            nextPage = page + 2
        case (.spread, .right):
            guard page - 2 >= -1 else { return nil }
            nextPage = page - 2
        case (.single, .left):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        case (.single, .right):
            guard page - 1 >= 0 else { return nil }
            nextPage = page - 1
        }
        
        let vc = createChildViewController(nextPage)
        
        return (vc, nextPage)
    }
    
    func viewControllerForPageRight(pageType: PageType, pageDirection: PageDirection, page: Int) -> (UIViewController, Int)? {
        
        var nextPage = 0
        
        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page - 2 >= -1 else { return nil }
            nextPage = page - 2
        case (.spread, .right):
            guard page + 2 < count else { return nil }
            nextPage = page + 2
        case (.single, .left):
            guard page - 1 >= 0 else { return nil }
            nextPage = page - 1
        case (.single, .right):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        }
        
        let vc = createChildViewController(nextPage)
        
        return (vc, nextPage)
    }
    
    func viewControllerForShiftPageLeft(pageType: PageType, pageDirection: PageDirection, page: Int) -> (UIViewController, Int)? {
        
        var nextPage = 0

        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        case (.spread, .right):
            guard page - 1 >= -1 else { return nil }
            nextPage = page - 1
        case (.single, .left):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        case (.single, .right):
            guard page - 1 >= 0 else { return nil }
            nextPage = page - 1
        }
        
        let vc = createChildViewController(nextPage)
        
        return (vc, nextPage)
    }
    
    func viewControllerForShiftPageRight(pageType: PageType, pageDirection: PageDirection, page: Int) -> (UIViewController, Int)? {
        
        var nextPage = 0

        
        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page - 1 >= -1 else { return nil }
            nextPage = page - 1
        case (.spread, .right):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        case (.single, .left):
            guard page - 1 >= 0 else { return nil }
            nextPage = page - 1
        case (.single, .right):
            guard page + 1 < count else { return nil }
            nextPage = page + 1
        }
        
        
        let vc = createChildViewController(nextPage)
        
        return (vc, nextPage)
    }
    
    func createChildViewController(_ nextPage: Int) -> UIViewController {
        switch pageType {
        case .single:
            let vc = SinglePageViewController(nibName: nil, bundle: nil)
            vc.page = nextPage
            vc.archiver = archiver
            return vc
        case .spread:
            let vc = SpreadPageViewController(nibName: nil, bundle: nil)
            if pageDirection == .left {
                vc.page = nextPage
                vc.leftPage = nextPage + 1
                vc.rightPage = nextPage
                vc.archiver = archiver
            } else if pageDirection == .right {
                vc.page = nextPage
                vc.leftPage = nextPage
                vc.rightPage = nextPage + 1
                vc.archiver = archiver
            }
            return vc
        }
    }
    
    init(archiver: Archiver, page: Int, pageDirection: PageDirection, pageType: PageType) {
        self.pageDirection = pageDirection
        self.pageType = pageType
        self.archiver = archiver
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing : 12])
        self.delegate = self
        self.dataSource = self
        self.page = page
        
        self.edgesForExtendedLayout = []
        self.count = archiver.entries.count
        
        if self.page < 0 && pageType == .single {
            self.page = 0
        }
        if self.page >= count && pageType == .single {
            self.page = count - 1
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setPage(notification:)), name: Notification.Name("SelectPage"), object: nil)
        
        let vc = createChildViewController(self.page)
        self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    @objc func setPage(notification : Notification) {
        guard let userInfo = notification.userInfo,
            let identifier = userInfo["identifier"] as? String,
            let page = userInfo["page"] as? Int else {
            return
        }
        
        if identifier == archiver.identifier {
            self.page = page
            let vc = createChildViewController(self.page)
            self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
    }
    
    
    var isAnimatingThumbnailView = false
    
    var constraint: NSLayoutConstraint?
    
    var currentThumbnailViewController: ThumbnailViewController? {
        return self.children.compactMap { (vc) -> ThumbnailViewController? in
            return vc as? ThumbnailViewController
        }.first
    }
    
    func toggleThumbnails() {
    
//        #if targetEnvironment(macCatalyst)
//        guard !isAnimatingThumbnailView else { return }
//        titleBarHidden = !titleBarHidden
//        #else
//        guard !isAnimatingControllerView && !isAnimatingThumbnailView else { return }
//        toggleToolbar()
//        #endif
//
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
            let apage = self.page

            let thumbnailViewController = ThumbnailViewController(archiver: self.archiver, pageDirection: pageDirection, startAt: apage)
            
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

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let singlePageViewController = self.viewControllers?.first as? SinglePageViewController {
                self.page = singlePageViewController.page
            } else if let spreadPageViewController = self.viewControllers?.first as? SpreadPageViewController {
                self.page = spreadPageViewController.page
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let (vc, _) = viewControllerForPageLeft(pageType: pageType, pageDirection: pageDirection, page: page) {
            return vc
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let (vc, _) = viewControllerForPageRight(pageType: pageType, pageDirection: pageDirection, page: page) {
            return vc
        }
        return nil
    }
    
}

extension PageViewController {

    func pageForward() {
        if pageDirection == .left {
            pageLeft()
        } else {
            pageRight()
        }
    }

    func pageLeft() {
        if let (vc, nextPage) = viewControllerForPageLeft(pageType: pageType, pageDirection: pageDirection, page: page) {
            if !paging {
                page = nextPage
                paging = true
                self.setViewControllers([vc], direction: .reverse, animated: true) { (succeeded) in
                    self.paging = false
                }
            }
        }
    }
    
    func pageRight() {
        if let (vc, nextPage) = viewControllerForPageRight(pageType: pageType, pageDirection: pageDirection, page: page) {
            if !paging {
                page = nextPage
                paging = true
                self.setViewControllers([vc], direction: .forward, animated: true) { (succeeded) in
                    self.paging = false
                }
            }
        }
    }
    
    func shiftPageLeft() {
        if let (vc, nextPage) = viewControllerForShiftPageLeft(pageType: pageType, pageDirection: pageDirection, page: page) {
            if !paging {
                page = nextPage
                paging = true
                self.setViewControllers([vc], direction: .reverse, animated: (pageType == .single)) { (succeeded) in
                    self.paging = false
                }
            }
        }
    }
    
    func shiftPageRight() {
        if let (vc, nextPage) = viewControllerForShiftPageRight(pageType: pageType, pageDirection: pageDirection, page: page) {
            if !paging {
                page = nextPage
                paging = true
                self.setViewControllers([vc], direction: .forward, animated: (pageType == .single)) { (succeeded) in
                    self.paging = false
                }
            }
        }
    }
}

// MARK: - Toolbar for Mac Catalyst

#if targetEnvironment(macCatalyst)
extension PageViewController: NSToolbarDelegate {
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "selectStyle")) {
            let group = NSToolbarItemGroup.init(itemIdentifier: NSToolbarItem.Identifier(rawValue: "selectStyle"), images: [UIImage(named: "book")!, UIImage(named: "single")!], selectionMode: .selectOne, labels: ["Spread", "Single"], target: self, action: #selector(PageViewController.togglePageTypeOnToolbar))
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
                                                action: #selector(PageViewController.togglePageDirectionOnToolbar))
            group.setSelected(true, at: 0)
            selectDirectionToolbar = group
            return group
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goLeft")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goLeft"))
            item.image = UIImage(systemName: "arrow.left")
            item.target = self
//            item.action = #selector(shiftPageLeft(_:))
            item.isBordered = true
            return item
        }
        
        if (itemIdentifier == NSToolbarItem.Identifier(rawValue: "goRight")) {
            let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "goRight"))
            item.image = UIImage(systemName: "arrow.right")
            item.target = self
//            item.action = #selector(shiftPageRight(_:))
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

// MARK: - UIGestureRecongnizer

extension PageViewController {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let v = touch.view {
            if let vc = currentThumbnailViewController {
                if v.isDescendant(of: vc.view) {
                    return false
                }
            }
//            if let toolView = self.toolView {
//                if v.isDescendant(of: toolView) {
//                    return false
//                }
//            }
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
                self.pageLeft()
                
            } else if rightArea.contains(tap) {
                self.pageRight()
            } else {
                let rect = self.view.bounds.inset(by: self.view.safeAreaInsets)
                if rect.contains(tap) {
                    toggleThumbnails()
                }
            }
            
        }
    }
}


