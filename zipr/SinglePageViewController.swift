//
//  SinglePageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/10.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class SinglePageViewControllerOld: PageViewControllerOld {
    
    @IBOutlet var imageView: UIImageView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }

    override func didLoadImage(_ image: UIImage, at index: Int) {
        // overload
        self.imageView?.image = image
    }
}
