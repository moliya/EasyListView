//
//  MainViewController.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/17.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit
import EasyListView

class MainViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell1: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "示例-表单"
            cell.height(44)
            cell.onTap = { [unowned self] in
                self.navigationController?.pushViewController(FormListController(), animated: true)
            }
            
            return cell
        }()
        scrollView.easy.appendView(cell1).spacing(10)
        
        let cell2: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "示例-列表"
            cell.height(44)
            cell.onTap = { [unowned self] in
                self.navigationController?.pushViewController(UserListController(), animated: true)
            }
            
            return cell
        }()
        scrollView.easy.appendView(cell2).spacing(0.5)
    }
}
