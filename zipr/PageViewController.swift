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

enum PageOffset {
    case no
    case one
}

protocol PageViewControllerProtocol: UIViewController {
    var page: Int { get set }
}

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var archiver: Archiver?
    
    let pageDirection :PageDirection
    let pageType: PageType
    let pageOffset: PageOffset
    
    var page: Int = 0
    
    var count: Int = 10

    required init?(coder: NSCoder) {
        self.pageDirection = .left
        self.pageType = .single
        self.pageOffset = .no
        super.init(coder: coder)
    }
    
    func genVC() -> PageViewControllerProtocol {
        switch pageType {
        case .single:
            let vc = SinglePageViewController(nibName: nil, bundle: nil)
            vc.page = page
            return vc
        case .spread:
            let vc = SpreadPageViewController(nibName: nil, bundle: nil)
            if pageDirection == .left {
                vc.leftPage = page + 1
                vc.rightPage = page
            } else if pageDirection == .right {
                vc.leftPage = page
                vc.rightPage = page + 1
            }
            return vc
        }
    }
    
    init(archiver: Archiver, page: Int, pageDirection: PageDirection, pageType: PageType, pageOffset: PageOffset) {
        self.pageOffset = pageOffset
        self.pageDirection = pageDirection
        self.pageType = pageType
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing : 12])
        self.delegate = self
        self.dataSource = self
        self.page = page
        self.archiver = archiver
        self.view.backgroundColor = .purple
        
        if self.page < 0 && pageType == .single {
            self.page = 0
        }
        if self.page >= count && pageType == .single {
            self.page = count - 1
        }
        
        let vc = genVC()
        self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            if key.modifierFlags.contains(.alternate) {
                if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                    if pageType == .spread {
                        if pageDirection == .left {
                            if page + 1 < count {
                                page = page + 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .reverse, animated: false, completion: nil)
                            }
                        } else if pageDirection == .right {
                            if page - 1 >= -1 {
                                page = page - 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                            }
                        }
                    } else if pageType == .single {
                        if pageDirection == .left {
                            if page + 1 < count {
                                page = page + 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                            }
                        } else if pageDirection == .right {
                            if page - 1 >= 0 {
                                page = page - 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                            }
                        }
                    }
                } else if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                    if pageType == .spread {
                        if pageDirection == .left {
                            if page - 1 >= -1 {
                                page = page - 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
                            }
                        } else if pageDirection == .right {
                            if page + 1 < count {
                                page = page + 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                            }
                        }
                    } else if pageType == .single {
                        if pageDirection == .left {
                            if page - 1 >= 0 {
                                page = page - 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                            }
                        } else if pageDirection == .right {
                            if page + 1 < count {
                                page = page + 1
                                let vc = genVC()
                                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                if pageDirection == .left {
                    if pageType == .single {
                        if page + 1 < count {
                            page = page + 1
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                        }
                    } else if pageType == .spread {
                        if page + 2 < count {
                            page = page + 2
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                        }
                    }
                } else if pageDirection == .right {
                    if pageType == .single {
                        if page - 1 >= 0 {
                            page = page - 1
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                        }
                    } else if pageType == .spread {
                        if page - 2 > -2 {
                            page = page - 2
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
                        }
                    }
                }
                
                didHandleEvent = true
            } else if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                if pageDirection == .left {
                    if pageType == .single {
                        if page - 1 >= 0 {
                            page = page - 1
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                        }
                    } else if pageType == .spread {
                        if page - 2 >= -1 {
                            page = page - 2
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                        }
                    }
                } else if pageDirection == .right {
                    if pageType == .single {
                        if page + 1 < count {
                            page = page + 1
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                        }
                    } else if pageType == .spread {
                        if page + 2 <= count {
                            page = page + 2
                            let vc = genVC()
                            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
                        }
                    }
                }
                didHandleEvent = true
            }
        }
        
        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if completed {
//            if let con = pageViewController.viewControllers?.last as? ImageViewController {
//                self.imageViewController = con
//            }
//        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        if let viewController = viewController as? ImageViewController {
//            let index = viewController.index + 1
//            if collection.count <= index {
//                return nil
//            }
//            return ImageViewController(index: index, imageCollectionViewController:imageCollectionViewController, isDark:isDark)
//        }
        
        
        guard let previousPageViewController = viewController as? PageViewControllerProtocol else {
            return nil
        }
        
        let vc = genVC()
        
        vc.page = previousPageViewController.page - 1
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        if let viewController = viewController as? ImageViewController {
//            let index = viewController.index - 1
//            if index < 0 {
//                return nil
//            }
//            return ImageViewController(index: index, imageCollectionViewController:imageCollectionViewController, isDark:isDark)
//        }
        
        guard let previousPageViewController = viewController as? PageViewControllerProtocol else {
            return nil
        }
        
        let vc = genVC()
        
        vc.page = previousPageViewController.page + 1
        return vc
    }
    
}
