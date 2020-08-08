//
//  ViewController.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/6/11.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let vc = ObjcViewController()
            self.present(vc, animated: true, completion: nil)
        }
    }


}

