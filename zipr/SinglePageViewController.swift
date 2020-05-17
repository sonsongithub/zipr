//
//  SinglePageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/16.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class SinglePageViewController: UIViewController, PageViewControllerProtocol {
    let label = UILabel(frame: .zero)
    
    var page: Int = 0 {
        didSet {
            label.text = String(format: "%d", page)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22)
        
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
}
