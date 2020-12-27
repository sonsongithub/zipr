//
//  FolderViewController.swift
//  zipr
//
//  Created by sonson on 2020/12/25.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit


class FolderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let loader = FolderThumbnailLoader()
    var contents: [String] = []
    let path: URL
    let collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        self.collectionView = nil
        self.path = URL(fileURLWithPath: "")
        super.init(coder: coder)
        fatalError("Can not create this view controller with NSCoder")
    }
    
    deinit {
        print("deinit FolderViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            print(self.path)
            let paths = try FileManager.default.subpathsOfDirectory(atPath: self.path.path)
            let array = paths.filter { (pathAsString) -> Bool in
                print(pathAsString)
                let tmp = pathAsString as NSString
                return (tmp.pathExtension == "zip")
            }
            contents = array.map({ (fileName) -> String in
                return self.path.appendingPathComponent(fileName).path
            })
        } catch {
            print(error)
        }
        print(contents)
    }
    
    init(_ url: URL) {
        self.collectionView = {
           
            let layout: UICollectionViewFlowLayout = FolderViewFlowLayout()
            let collectionView = UICollectionView( frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            collectionView.alwaysBounceHorizontal = false
            
            collectionView.register(FolderViewCell.self, forCellWithReuseIdentifier: "FolderViewCell")
            return collectionView
        }()
        self.path = url
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        loader.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveImage(notification:)), name: Notification.Name("ZipThumbnail"), object: nil)
    }
    
    @objc func didReceiveImage(notification : Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let image = userInfo["image"] as? UIImage else { return }
        guard let path = userInfo["path"] as? String else { return }
        
        let cells: [FolderViewCell] = self.collectionView.visibleCells.compactMap { (cell) -> FolderViewCell? in
            return cell as? FolderViewCell
        }.filter { (cell) -> Bool in
            return cell.path == path
        }
        
        if let cell = cells.first {
            cell.imageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 200)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let _ = cell as? ThumbnailViewCell {
//            archiver.cancel( indexPath.item)
//        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.collectionView.visibleCells.forEach { (cell) in
//            if let cell = cell as? ThumbnailViewCell {
//                if cell.imageView.image == nil {
//                    if let image = archiver.read(at: cell.page) {
//                        cell.imageView.image = image
//                    }
//                }
//            }
//        }
//    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.collectionView.visibleCells.forEach { (cell) in
//            if let cell = cell as? ThumbnailViewCell {
//                if cell.imageView.image == nil {
//                    if let image = archiver.read(at: cell.page) {
//                        cell.imageView.image = image
//                    }
//                }
//            }
//        }
//
//    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderViewCell", for: indexPath) as! FolderViewCell
        
        cell.path = contents[indexPath.item]
        
        if let image = loader.cache(contents[indexPath.item]) {
            cell.imageView.image = image
        } else {
            loader.append(contents[indexPath.item])
        }
        
        cell.textLabel.text = contents[indexPath.item]
        
    
//        if let image = archiver.read(at: indexPath.item, startLoading: !collectionView.isDragging) {
//            cell.imageView.image = image
//            cell.page = indexPath.item
//            cell.identifier = archiver.identifier
//            cell.activityIndicatorView.stopAnimating()
//        } else {
//            cell.page = indexPath.item
//            cell.identifier = archiver.identifier
//        }
        return cell
    }
    
}
    
