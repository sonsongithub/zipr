//
//  SpreadPageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/16.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class SpreadPageViewController: UIViewController, PageViewControllerProtocol {
    
    let leftLabel = UILabel(frame: .zero)
    let rightLabel = UILabel(frame: .zero)
    
    var page: Int = 0 {
        didSet {
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftLabel.textAlignment = .center
        leftLabel.font = UIFont.systemFont(ofSize: 22)
        leftLabel.backgroundColor = .red
        
        rightLabel.textAlignment = .center
        rightLabel.font = UIFont.systemFont(ofSize: 22)
        
        /// Instantiate StackView and configure it
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        /// Setup StackView's constraints to its superview
        view.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
    }
}
