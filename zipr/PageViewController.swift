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

protocol PageViewControllerProtocol: UIViewController {
    var page: Int { get set }
}

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var archiver: Archiver?
    
    let pageDirection :PageDirection
    let pageType: PageType
    
    var page: Int = 0
    
    var count: Int = 11

    required init?(coder: NSCoder) {
        self.pageDirection = .left
        self.pageType = .single
        super.init(coder: coder)
    }
    
    func leftNextViewController(pageType: PageType, pageDirection: PageDirection, page: Int) -> (PageViewControllerProtocol, Int)? {
        
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
    
    func rightNextViewController(pageType: PageType, pageDirection: PageDirection, page: Int) -> (PageViewControllerProtocol, Int)? {
        
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
    
    func createChildViewController(_ nextPage: Int) -> PageViewControllerProtocol {
        switch pageType {
        case .single:
            let vc = SinglePageViewController(nibName: nil, bundle: nil)
            vc.page = nextPage
            return vc
        case .spread:
            let vc = SpreadPageViewController(nibName: nil, bundle: nil)
            if pageDirection == .left {
                vc.page = nextPage
                vc.leftPage = nextPage + 1
                vc.rightPage = nextPage
            } else if pageDirection == .right {
                vc.page = nextPage
                vc.leftPage = nextPage
                vc.rightPage = nextPage + 1
            }
            return vc
        }
    }
    
    init(archiver: Archiver?, page: Int, pageDirection: PageDirection, pageType: PageType) {
        self.pageDirection = pageDirection
        self.pageType = pageType
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing : 12])
        self.delegate = self
        self.dataSource = self
        self.page = page
        self.archiver = archiver
        
        if self.page < 0 && pageType == .single {
            self.page = 0
        }
        if self.page >= count && pageType == .single {
            self.page = count - 1
        }
        
        let vc = createChildViewController(self.page)
        self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "S", modifierFlags: [.command], action: #selector(aaa(command:))),
            UIKeyCommand(input: "P", modifierFlags: [.command], action: #selector(aaa(command:))),
            UIKeyCommand(input: "O", modifierFlags: [.command], action: #selector(ccc(command:))),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(handleShortcutCommand(command:))),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(handleShortcutCommand(command:))),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command], action: #selector(bbb(command:))),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], action: #selector(bbb(command:))),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.alternate], action: #selector(handleShortcutCommand(command:))),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.alternate], action: #selector(handleShortcutCommand(command:)))
        ]

        return commands
    }
    
    @objc func aaa(command: UIKeyCommand) {
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
    
    @objc func bbb(command: UIKeyCommand) {
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
    
    @objc func ccc(command: UIKeyCommand) {
        if command.modifierFlags.contains(.command) {
            if command.input == "O" {
                print("o")
            }
        }
    }

    @objc func handleShortcutCommand(command: UIKeyCommand) {
        if command.modifierFlags.contains(.alternate) {
            if command.input == UIKeyCommand.inputLeftArrow {
                pageToLeftByAPage()
            }
            if command.input == UIKeyCommand.inputRightArrow {
                pageToRightByAPage()
            }
        } else {
            if command.input == UIKeyCommand.inputLeftArrow {
                pageToLeft()
            }
            if command.input == UIKeyCommand.inputRightArrow {
                pageToRight()
            }
        }
    }
    
    func pageToLeft() {

        if let (vc, nextPage) = leftNextViewController(pageType: pageType, pageDirection: pageDirection, page: page) {
            page = nextPage
            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
        }
        
//        switch (pageType, pageDirection) {
//        case (.spread, .left):
//            guard page + 2 < count else { return }
//            page = page + 2
//        case (.spread, .right):
//            guard page - 2 >= -1 else { return }
//            page = page - 2
//        case (.single, .left):
//            guard page + 1 < count else { return }
//            page = page + 1
//        case (.single, .right):
//            guard page - 1 >= 0 else { return }
//            page = page - 1
//        }
//
//        let vc = genVC(page)
//        self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
    }
    
    func pageToRight() {
        
        if let (vc, nextPage) = rightNextViewController(pageType: pageType, pageDirection: pageDirection, page: page) {
            page = nextPage
            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
        
//        switch (pageType, pageDirection) {
//        case (.spread, .left):
//            guard page - 2 >= -1 else { return }
//            page = page - 2
//        case (.spread, .right):
//            guard page + 2 < count else { return }
//            page = page + 2
//        case (.single, .left):
//            guard page - 1 >= 0 else { return }
//            page = page - 1
//        case (.single, .right):
//            guard page + 1 < count else { return }
//            page = page + 1
//        }
//
//        let vc = createChildViewController(page)
//        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
    func pageToLeftByAPage() {
        
        var animated = false
        
        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page + 1 < count else { return }
            page = page + 1
        case (.spread, .right):
            guard page - 1 >= -1 else { return }
            page = page - 1
        case (.single, .left):
            guard page + 1 < count else { return }
            page = page + 1
            animated = true
        case (.single, .right):
            guard page - 1 >= 0 else { return }
            page = page - 1
            animated = true
        }
        
        let vc = createChildViewController(page)
        self.setViewControllers([vc], direction: .reverse, animated: animated, completion: nil)
    }
    
    func pageToRightByAPage() {
        
        var animated = false
        
        switch (pageType, pageDirection) {
        case (.spread, .left):
            guard page - 1 >= -1 else { return }
            page = page - 1
        case (.spread, .right):
            guard page + 1 < count else { return }
            page = page + 1
        case (.single, .left):
            guard page - 1 >= 0 else { return }
            page = page - 1
            animated = true
        case (.single, .right):
            guard page + 1 < count else { return }
            page = page + 1
            animated = true
        }
        
        let vc = createChildViewController(page)
        self.setViewControllers([vc], direction: .forward, animated: animated, completion: nil)
    }
    
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
        
        if let (vc, _) = leftNextViewController(pageType: pageType, pageDirection: pageDirection, page: page) {
            return vc
        }
        
        return nil

//        switch (pageType, pageDirection) {
//        case (.spread, .left):
//            guard page + 2 < count else { return nil }
//            let nextPage = page + 2
//            let vc = genVC(nextPage)
//            return vc
//        case (.spread, .right):
//            guard page - 2 >= -1 else { return nil }
//            let nextPage = page - 2
//            let vc = genVC(nextPage)
//            return vc
//        case (.single, .left):
//            guard page + 1 < count else { return nil }
//            let nextPage = page + 1
//            let vc = genVC(nextPage)
//            return vc
//        case (.single, .right):
//            guard page - 1 >= 0 else { return nil }
//            let nextPage = page - 1
//            let vc = genVC(nextPage)
//            return vc
//        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let (vc, _) = rightNextViewController(pageType: pageType, pageDirection: pageDirection, page: page) {
            return vc
        }
        
        return nil
    }
    
}
