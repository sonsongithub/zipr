//
//  ThumbnailViewController.swift
//  zipr
//
//  Created by sonson on 2020/06/05.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let archiver: Archiver!
    let startPage: Int
    let collectionView: UICollectionView!
    var pageDirection :PageDirection {
        didSet {
            collectionView.setCollectionViewLayout(ThumbnailViewFlowLayout(pageDirection: pageDirection), animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        self.pageDirection = .left
        self.archiver = nil
        self.collectionView = nil
        self.startPage = 0
        super.init(coder: coder)
        fatalError("Can not create this view controller with NSCoder")
    }
    
    init(archiver: Archiver, pageDirection: PageDirection, startAt page: Int) {
        self.pageDirection = pageDirection
        self.archiver = archiver
        self.startPage = page
        self.collectionView = {
            let layout: UICollectionViewFlowLayout = ThumbnailViewFlowLayout(pageDirection: pageDirection)

            let collectionView = UICollectionView( frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            collectionView.alwaysBounceHorizontal = true
            
            collectionView.register(ThumbnailViewCell.self, forCellWithReuseIdentifier: "ThumbnailViewCell")
            return collectionView
        }()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(collectionView)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.scrollToItem(at: IndexPath(item: self.startPage, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 200)
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
        if let _ = cell as? ThumbnailViewCell {
            archiver.cancel( indexPath.item)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailViewCell", for: indexPath) as! ThumbnailViewCell
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
