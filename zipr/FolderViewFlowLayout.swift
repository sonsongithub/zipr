//
//  FolderViewFlowLayout.swift
//  zipr
//
//  Created by sonson on 2020/12/25.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class FolderViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .vertical
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 0
        self.itemSize = CGSize(width: 200, height: 200)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
//        return (pageDirection == .left)
//    }
    
//    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
//        return UIUserInterfaceLayoutDirection.rightToLeft
//    }
}
