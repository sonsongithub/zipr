//
//  SpreadPageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/16.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class SpreadPageViewController: UIViewController {
    
    let leftLabel = UILabel(frame: .zero)
    let rightLabel = UILabel(frame: .zero)
    
    let leftImageView = UIImageView(frame: .zero)
    let rightImageView = UIImageView(frame: .zero)
    
    let leftActivityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    let rightActivityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    var page: Int = 0
    
    var archiver: Archiver!
    
    var leftPage: Int = 0 {
        didSet {
            leftLabel.text = String(format: "%d", leftPage)
        }
        
    }
    var rightPage: Int = 0 {
        didSet {
            rightLabel.text = String(format: "%d", rightPage)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let archiver = self.archiver {
            
            if let image = archiver.read(at: leftPage) {
                leftImageView.image = image
                leftActivityIndicatorView.stopAnimating()
            } else {
                leftActivityIndicatorView.startAnimating()
            }
            
            if let image = archiver.read(at: rightPage) {
                rightImageView.image = image
                rightActivityIndicatorView.stopAnimating()
            } else {
                rightActivityIndicatorView.startAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.clipsToBounds = true
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.clipsToBounds = true
        
        leftActivityIndicatorView.hidesWhenStopped = true
        rightActivityIndicatorView.hidesWhenStopped = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorHandle(notification:)), name: Notification.Name("LoadedFailed"), object: nil)
       
        do {
            /// Instantiate StackView and configure it
            let stackView = UIStackView(frame: .zero)
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fillEqually
            stackView.spacing = 0
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(stackView)

            /// Setup StackView's constraints to its superview
            view.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true

            stackView.addArrangedSubview(leftImageView)
            stackView.addArrangedSubview(rightImageView)
        }
        
        do {
            /// Instantiate StackView and configure it
            let baseStackView = UIStackView(frame: .zero)
            baseStackView.axis = .horizontal
            baseStackView.alignment = .center
            baseStackView.distribution = .fillEqually
            baseStackView.spacing = 0
            baseStackView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(baseStackView)
            
            /// Setup StackView's constraints to its superview
            view.topAnchor.constraint(equalTo: baseStackView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: baseStackView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: baseStackView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: baseStackView.trailingAnchor).isActive = true
            
            let leftBaseView = UIView(frame: .zero)
            let rightBaseView = UIView(frame: .zero)
            
            baseStackView.addArrangedSubview(leftBaseView)
            baseStackView.addArrangedSubview(rightBaseView)
            
            leftBaseView.addSubview(leftActivityIndicatorView)
            leftActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            leftBaseView.translatesAutoresizingMaskIntoConstraints = false
            leftActivityIndicatorView.centerXAnchor.constraint(equalTo: (leftBaseView.centerXAnchor), constant: 0).isActive = true
            leftActivityIndicatorView.centerYAnchor.constraint(equalTo: (leftBaseView.centerYAnchor), constant: 0).isActive = true

            rightBaseView.addSubview(rightActivityIndicatorView)
            rightActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            rightBaseView.translatesAutoresizingMaskIntoConstraints = false
            rightActivityIndicatorView.centerXAnchor.constraint(equalTo: (rightBaseView.centerXAnchor), constant: 0).isActive = true
            rightActivityIndicatorView.centerYAnchor.constraint(equalTo: (rightBaseView.centerYAnchor), constant: 0).isActive = true
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
                    if self.leftPage == page {
                        self.leftActivityIndicatorView.stopAnimating()
                        
                    }
                    if self.rightPage == page {
                        self.rightActivityIndicatorView.stopAnimating()
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
            if let identifier = self.archiver?.identifier {
                if sent_identifier == identifier {
                    if self.leftPage == page {
                        self.leftImageView.image = image
                        self.leftActivityIndicatorView.stopAnimating()
                        
                    }
                    if self.rightPage == page {
                        self.rightImageView.image = image
                        self.rightActivityIndicatorView.stopAnimating()
                    }
                }
            }
        }
        
    }
}
