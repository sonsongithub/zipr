//
//  PageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/14.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit


class PageViewControllerOld: UIViewController {
    
    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let activity = NSUserActivity(activityType: "ok")
        activity.persistentIdentifier = NSUUID().uuidString
        self.userActivity = activity
    }
    
    @objc final func handle(notification : Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let image = userInfo["image"] as? UIImage else {
            return
        }
        
        guard let page = userInfo["page"] as? Int else {
            return
        }
        
        guard let sent_identifier = userInfo["identifier"] as? String else {
            return
        }
        
        DispatchQueue.main.async {
            guard let identifider = self.userActivity?.persistentIdentifier else {
                return
            }
            if sent_identifier == identifider {
                self.didLoadImage(image, at: page)
            }
        }
    }
    
    func didLoadImage(_ image: UIImage, at index: Int) {
        // overload
    }
    
    
}
