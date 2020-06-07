//
//  ThumbnailViewController.swift
//  zipr
//
//  Created by sonson on 2020/06/05.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class MyCell: UICollectionViewCell {
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
            let page = userInfo["page"] as? Int,
            let sent_identifier = userInfo["identifier"] as? String
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

class MyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    let pageDirection: PageDirection
    
    init(pageDirection: PageDirection) {
        self.pageDirection = pageDirection
        super.init()
        //各々の設計に合わせて調整
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 0
        self.itemSize = CGSize(width: 180, height: 200)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return (pageDirection == .left)
    }
    
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return UIUserInterfaceLayoutDirection.rightToLeft
    }
}

class ThumbnailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let archiver: Archiver!
    let collectionView: UICollectionView!
    var pageDirection :PageDirection {
        didSet {
            collectionView.setCollectionViewLayout(MyCollectionViewFlowLayout(pageDirection: pageDirection), animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        self.pageDirection = .left
        self.archiver = nil
        self.collectionView = nil
        super.init(coder: coder)
        fatalError("Can not create this view controller with NSCoder")
    }
    
    init(archiver: Archiver, pageDirection: PageDirection) {
        self.pageDirection = pageDirection
        self.archiver = archiver
        self.collectionView = {
            //セルのレイアウト設計
            let layout: UICollectionViewFlowLayout = MyCollectionViewFlowLayout(pageDirection: pageDirection)

            let collectionView = UICollectionView( frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            collectionView.alwaysBounceHorizontal = true
            //セルの登録
            collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
            return collectionView
        }()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(collectionView)
        
        // 磨りガラス効果のViewを生成
        func blurEffectView(fromBlurStyle style: UIBlurEffect.Style, frame: CGRect) -> UIVisualEffectView {
            let effect = UIBlurEffect(style: style)
            let blurView = UIVisualEffectView(effect: effect)
            blurView.frame = frame
            return blurView
        }
        
        let effect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: effect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(blurView)
        
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.sendSubviewToBack(blurView)

        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: 100, height: 200)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archiver.entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let userInfo: [String: Any] = [
            "page": indexPath.item,
            "identifier": archiver.identifier
        ]
        NotificationCenter.default.post(name: Notification.Name("SelectPage"), object: nil, userInfo: userInfo)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _ = cell as? MyCell {
            archiver.cancel( indexPath.item)
        }
    }

//    public override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//           if let cell = cell as? ImageCollectionViewCell {
//               cell.cancelDownloadingImage()
//           }
//       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCell
        cell.textLabel.text = String(indexPath.row + 1)
        
        if archiver.read(at: indexPath.item) {
            cell.page = indexPath.item
            cell.identifier = archiver.identifier
        } else {
            // error
            // no page
        }
        
        return cell
    }
    
}
