//
//  PageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/15.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

enum PageDirection {
    case left
    case right
}

enum PageType {
    case single
    case spread
}

class PageViewController: UIPageViewController {
    
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
        
        let vc = createChildViewController(self.page)
        self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
}

extension PageViewController {
    
    override var keyCommands: [UIKeyCommand]? {
        #if targetEnvironment(macCatalyst)
        // workaround
        // Mac Catalyst can not handle space key which is registered by UIMenu API.
        let commands = [
            UIKeyCommand(title: "Page Forward", image: nil, action: #selector(pageForward(command:)), input: " ", modifierFlags: [], propertyList: nil, alternates: [], discoverabilityTitle: "Page Forward", attributes: [], state: .off),
        ]
        #else
        let commands = [
            UIKeyCommand(title: "Toggle Page", image: nil, action: #selector(togglePageType(command:)), input: "S", modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Page Left", attributes: [], state: .off),
            UIKeyCommand(title: "Toggle Page", image: nil, action: #selector(togglePageType(command:)), input: "P", modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Page Left", attributes: [], state: .off),
            
            UIKeyCommand(title: "Open...", image: nil, action: #selector(handleFile(command:)), input: "O", modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Open...", attributes: [], state: .off),
            UIKeyCommand(title: "Open as New Window", image: nil, action: #selector(handleFile(command:)), input: "O", modifierFlags: [.command, .shift], propertyList: nil, alternates: [], discoverabilityTitle: "Open as New Window", attributes: [], state: .off),
            
            UIKeyCommand(title: "Page Left", image: nil, action: #selector(handlePaging(command:)), input: UIKeyCommand.inputLeftArrow, modifierFlags: [], propertyList: nil, alternates: [], discoverabilityTitle: "Page Left", attributes: [], state: .off),
            UIKeyCommand(title: "Page Right", image: nil, action: #selector(handlePaging(command:)), input: UIKeyCommand.inputRightArrow, modifierFlags: [], propertyList: nil, alternates: [], discoverabilityTitle: "Page Right", attributes: [], state: .off),
            
            UIKeyCommand(title: "Toggle Direction", image: nil, action: #selector(togglePageDirection(command:)), input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Toggle Direction", attributes: [], state: .off),
            UIKeyCommand(title: "Toggle Direction", image: nil, action: #selector(togglePageDirection(command:)), input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Toggle Direction", attributes: [], state: .off),
            
            UIKeyCommand(title: "Shift Page Left", image: nil, action: #selector(handlePaging(command:)), input: UIKeyCommand.inputLeftArrow, modifierFlags: [.alternate], propertyList: nil, alternates: [], discoverabilityTitle: "Shift Page Left", attributes: [], state: .off),
            
            UIKeyCommand(title: "Shift Page Right", image: nil, action: #selector(handlePaging(command:)), input: UIKeyCommand.inputRightArrow, modifierFlags: [.alternate], propertyList: nil, alternates: [], discoverabilityTitle: "Shift Page Right", attributes: [], state: .off),
            
            UIKeyCommand(title: "Page Forward", image: nil, action: #selector(pageForward(command:)), input: " ", modifierFlags: [], propertyList: nil, alternates: [], discoverabilityTitle: "Page Forward", attributes: [], state: .off),
        ]
        #endif

        return commands
    }
    
    @objc func togglePageType(command: UIKeyCommand) {
        if command.modifierFlags.contains(.command) {
            if command.input == "S" {
                if let vc = self.parent as? BaseViewController {
                    vc.toggleSingle()
                }
            }
            if command.input == "P" {
                if let vc = self.parent as? BaseViewController {
                    vc.toggleSpread()
                }
            }
        }
    }
    
    @objc func togglePageDirection(command: UIKeyCommand) {
        if command.modifierFlags.contains(.command) {
            if command.input == UIKeyCommand.inputLeftArrow {
                if let vc = self.parent as? BaseViewController {
                    vc.toggleToLeft()
                }
            }
            if command.input == UIKeyCommand.inputRightArrow {
                if let vc = self.parent as? BaseViewController {
                    vc.toggleToRight()
                }
            }
        }
    }
    
    @objc func handleFile(command: UIKeyCommand) {
        if command.modifierFlags.contains(.command) {
            if command.modifierFlags.contains(.shift) {
                if command.input == "O" {
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
                }
            } else {
                if command.input == "O" {
                    if let vc = self.parent as? BaseViewController {
                        vc.openPicker()
                    }
                }
            }
        }
    }

    @objc func handlePaging(command: UIKeyCommand) {
        print("handlePaging")
        if command.modifierFlags.contains(.alternate) {
            if command.input == UIKeyCommand.inputLeftArrow {
                shiftPageLeft()
            }
            if command.input == UIKeyCommand.inputRightArrow {
                shiftPageRight()
            }
        } else {
            if command.input == UIKeyCommand.inputLeftArrow {
                pageLeft()
            }
            if command.input == UIKeyCommand.inputRightArrow {
                pageRight()
            }
        }
    }
    
    @objc func pageForward(command: UIKeyCommand) {
        pageForward()
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
