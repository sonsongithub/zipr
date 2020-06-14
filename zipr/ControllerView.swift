//
//  ControllerView.swift
//  zipr
//
//  Created by sonson on 2020/06/09.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class ControllerView: UIView {
    
    let openButton = UIButton(type: .roundedRect)
    let leftButton = UIButton(type: .roundedRect)
    let rightButton = UIButton(type: .roundedRect)
    
    let pageDirectionSwitcher = UISegmentedControl(items: [UIImage(named: "left_direction")!, UIImage(named: "right_direction")!])
    let pageTypeSwitcher = UISegmentedControl(items: [UIImage(named: "single")!, UIImage(named: "book")!])
    
    var pageDirection: PageDirection = .left {
        didSet {
            switch(pageDirection) {
            case .left:
                pageDirectionSwitcher.selectedSegmentIndex = 0
            case .right:
                pageDirectionSwitcher.selectedSegmentIndex = 1
            }
        }
    }
    var pageType: PageType = .single {
        didSet {
            switch(pageType) {
            case .single:
                pageTypeSwitcher.selectedSegmentIndex = 0
            case .spread:
                pageTypeSwitcher.selectedSegmentIndex = 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var regularHeight: CGFloat {
        return CGFloat(44 + 10 + 10)
    }
    
    static var compactHeight: CGFloat {
        return CGFloat(44) + CGFloat(10) + CGFloat(44) + CGFloat(10) + CGFloat(10)
    }
    
    func prepareViews() {

        let effect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: effect)
        
        self.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        let baseView = UIView(frame: .zero)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(baseView)
        baseView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        baseView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        baseView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        openButton.setImage(UIImage(systemName: "doc"), for: .normal)
        openButton.tintColor = .black
        openButton.translatesAutoresizingMaskIntoConstraints = false
        baseView.addSubview(openButton)
        
        openButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        openButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        openButton.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 10).isActive = true
        openButton.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 20).isActive = true
        
        leftButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        leftButton.tintColor = .black

        rightButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        rightButton.tintColor = .black

        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        baseView.addSubview(leftButton)
        baseView.addSubview(rightButton)

        leftButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        rightButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20).isActive = true
        rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 10).isActive = true
        
        
        baseView.addSubview(pageDirectionSwitcher)
        
        baseView.addSubview(pageTypeSwitcher)
        
        pageTypeSwitcher.translatesAutoresizingMaskIntoConstraints = false
        pageDirectionSwitcher.translatesAutoresizingMaskIntoConstraints = false
    
        pageTypeSwitcher.trailingAnchor.constraint(equalTo: baseView.centerXAnchor, constant: -20).isActive = true
        baseView.centerXAnchor.constraint(equalTo: pageDirectionSwitcher.leadingAnchor, constant: -20).isActive = true
        
        pageTypeSwitcher.widthAnchor.constraint(equalToConstant: 140).isActive = true
        pageDirectionSwitcher.widthAnchor.constraint(equalToConstant: 140).isActive = true
        pageTypeSwitcher.heightAnchor.constraint(equalToConstant: 44).isActive = true
        pageDirectionSwitcher.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        pageTypeSwitcher.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -10).isActive = true
        pageDirectionSwitcher.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant:-10).isActive = true
        
        leftButton.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 10).isActive = true
        rightButton.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 10).isActive = true
    }
}
