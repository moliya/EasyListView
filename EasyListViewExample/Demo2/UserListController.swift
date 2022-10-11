//
//  UserListController.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/17.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit
import EasyListView

class UserListController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        
        return scrollView
    }()
    
    var users = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        view.subviews(scrollView)
        view.layout(
            0,
            |scrollView|,
            0
        )
        
        scrollView.es.addPullToRefresh {[unowned self] in
            self.loadData()
        }
        scrollView.es.addInfiniteScrolling {[unowned self] in
            self.loadMoreData()
        }
        
        let activity = UIActivityIndicatorView(style: .gray)
        scrollView.subviews(activity)
        activity.centerInContainer()
        activity.startAnimating()
        loadData()
    }
    
    deinit {
        print("deinit")
    }
    
    @objc func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.users.count == 0 {
                self.scrollView.subviews.first { $0 is UIActivityIndicatorView }?.removeFromSuperview()
            }
            
            //删除旧的数据
            self.users.removeAll()
            self.scrollView.easy.deleteAll()
            
            //添加新数据
            for i in 1 ..< 11 {
                self.users.append("User No.\(i)")
            }
            
            for index in 0 ..< self.users.count {
                let view = self.scrollView.easy.disposableView {[unowned self] in
                    let cell = UserCell()
                    cell.set(name: self.users[index], avatar: UIImage(named: "avatar"))
                    
                    return cell
                }
                self.scrollView.easy.appendView(view)
            }
            
            if self.scrollView.header?.isRefreshing == true {
                self.scrollView.header?.stopRefreshing()
            }
        }
    }
    
    @objc func loadMoreData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let offset = self.users.count
            //添加新数据
            for i in 1 ..< 11 {
                self.users.append("User No.\(i + offset)")
            }
            
            self.scrollView.easy.beginUpdates()
            
            for index in offset ..< self.users.count {
                let view = self.scrollView.easy.disposableView {[unowned self] in
                    let cell = UserCell()
                    cell.set(name: self.users[index], avatar: UIImage(named: "avatar"))
                    return cell
                }
                self.scrollView.easy.appendView(view)
            }
            
            self.scrollView.easy.endUpdates()
            
            self.scrollView.footer?.stopRefreshing()
        }
    }
    
    
}

extension UserListController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.easy.triggerDisposable()
    }
}
