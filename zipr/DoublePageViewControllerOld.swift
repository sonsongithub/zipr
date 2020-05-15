//
//  DoublePageViewController.swift
//  zipr
//
//  Created by sonson on 2020/05/10.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit

class DoublePageViewControllerOld: PageViewControllerOld {
    
    @IBOutlet var leftImageView: UIImageView? = nil
    @IBOutlet var rightImageView: UIImageView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
    }

}
