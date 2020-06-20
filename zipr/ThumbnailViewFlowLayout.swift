//
//  ThumbnailViewFlowLayout.swift
//  zipr
//
//  Created by sonson on 2020/06/20.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailViewFlowLayout: UICollectionViewFlowLayout {
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
