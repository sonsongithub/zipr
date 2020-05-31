//
//  SinglePageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/16.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class SinglePageViewController: UIViewController {
    let label = UILabel(frame: .zero)
    let imageView = UIImageView(frame: .zero)
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    var archiver: Archiver!
    
    var page: Int = 0 {
        didSet {
            label.text = String(format: "%d", page)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let archiver = archiver {
            if archiver.read(at: page) {
                activityIndicatorView.startAnimating()
            } else {
                // error
                // no page
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidesWhenStopped = true
        imageView.contentMode = .scaleAspectFit
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorHandle(notification:)), name: Notification.Name("LoadedFailed"), object: nil)
        
        do {
            imageView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(imageView)

            /// Setup StackView's constraints to its superview
            imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(activityIndicatorView)
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
    }
    
    @objc func errorHandle(notification : Notification) {
        guard let userInfo = notification.userInfo,
            let page = userInfo["page"] as? Int,
            let sent_identifier = userInfo["identifier"] as? String
        else {
            return
        }
        
        DispatchQueue.main.async {
            if let identifier = self.archiver?.identifier {
                if sent_identifier == identifier {
                    if self.page == page {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func handle(notification : Notification) {
        guard let userInfo = notification.userInfo,
            let image = userInfo["image"] as? UIImage,
            let page = userInfo["page"] as? Int,
            let sent_identifier = userInfo["identifier"] as? String
        else {
            return
        }
        
        DispatchQueue.main.async {
            if sent_identifier == self.archiver.identifier {
                if self.page == page {
                    self.imageView.image = image
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }
        
    }
}
