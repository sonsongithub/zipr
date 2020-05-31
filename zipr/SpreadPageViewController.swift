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
            archiver.read(at: leftPage)
            archiver.read(at: rightPage)
            leftActivityIndicatorView.isHidden = false
            leftActivityIndicatorView.startAnimating()
            rightActivityIndicatorView.isHidden = false
            rightActivityIndicatorView.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.clipsToBounds = true
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
        
//        do {
//            leftLabel.textAlignment = .center
//            leftLabel.font = UIFont.systemFont(ofSize: 22)
//            leftLabel.backgroundColor = .red
//
//            rightLabel.textAlignment = .center
//            rightLabel.font = UIFont.systemFont(ofSize: 22)
//            rightLabel.backgroundColor = .red
//
//            /// Instantiate StackView and configure it
//            let stackView = UIStackView(frame: .zero)
//            stackView.axis = .horizontal
//            stackView.alignment = .center
//            stackView.distribution = .fillEqually
//            stackView.spacing = 0
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//
//            view.addSubview(stackView)
//
//            /// Setup StackView's constraints to its superview
//            view.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
//            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
//            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
//            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
//
//            stackView.addArrangedSubview(leftLabel)
//            stackView.addArrangedSubview(rightLabel)
//        }
        
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
    
    @objc func handle(notification : Notification) {
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
            if let identifier = self.archiver?.identifier {
                if sent_identifier == identifier {
                    if self.leftPage == page {
                        self.leftImageView.image = image
                        self.leftActivityIndicatorView.isHidden = true
                        self.leftActivityIndicatorView.stopAnimating()
                        
                    }
                    if self.rightPage == page {
                        self.rightImageView.image = image
                        self.rightActivityIndicatorView.isHidden = true
                        self.rightActivityIndicatorView.stopAnimating()
                    }
                }
            }
        }
        
    }
}
