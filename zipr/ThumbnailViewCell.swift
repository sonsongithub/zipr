//
//  ThumbnailViewCell.swift
//  zipr
//
//  Created by sonson on 2020/06/20.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailViewCell: UICollectionViewCell {
    let textLabel = UILabel(frame: .zero)
    let imageView = UIImageView(frame: .zero)
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    var identifier = ""
    var page = 0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicatorView.startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        imageView.contentMode = .scaleAspectFit
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        
        self.contentView.addSubview(textLabel)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        textLabel.textAlignment = .center

        textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
        self.contentView.bringSubviewToFront(textLabel)
        self.contentView.bringSubviewToFront(activityIndicatorView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorHandle(notification:)), name: Notification.Name("LoadedFailed"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @objc func errorHandle(notification : Notification) {
        guard let userInfo = notification.userInfo,
            let _ = userInfo["page"] as? Int,
            let _ = userInfo["identifier"] as? String
        else {
            return
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
            if sent_identifier == self.identifier {
                if self.page == page {
                    self.imageView.image = image
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }
        
    }
}
