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
    
    var archiver: Archiver?
    
    var page: Int = 0 {
        didSet {
            label.text = String(format: "%d", page)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let archiver = archiver {
            archiver.read(at: page)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
        
        do {
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 22)
            
            label.isHidden = true
            
            /// Instantiate StackView and configure it
            let stackView = UIStackView(frame: .zero)
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(stackView)

            /// Setup StackView's constraints to its superview
            view.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            
            stackView.addArrangedSubview(label)
        }
        
        do {
            /// Instantiate StackView and configure it
            let stackView = UIStackView(frame: .zero)
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(stackView)

            /// Setup StackView's constraints to its superview
            view.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
            
            stackView.addArrangedSubview(imageView)
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
                    print("self.page", self.page)
                    print("page", page)
                    if self.page == page {
                        self.imageView.image = image
                    }
                }
            }
        }
        
    }
}
