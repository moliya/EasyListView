//
//  EasyListCoordinator.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/8.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

@objc(KFEasyListUpdateOption)
public enum EasyListUpdateOption: Int {
    case animatedLayout = 0 //带动画的布局更新
    case onlyLayout //无动画的布局更新
    case noLayout //不进行布局
}

@objcMembers
open class EasyListCoordinator: NSObject {
    
    internal struct Element {
        var view: EasyListContentView
        var insets: UIEdgeInsets = .zero
        var identifier: String?
        var deleting: Bool = false
        var inserting: Bool = false
    }
    
    public weak private(set) var scrollView: UIScrollView?
    
    //全局内边距
    public var globalEdgeInsets: UIEdgeInsets = .zero
    //全局元素间距
    public var globalSpacing: CGFloat = 0
    //动画持续时间（包括插入、删除），为0则无动画
    public var animationDuration: TimeInterval = 0.3
    
    internal var elements = [Element]()
    internal var disposableElements = [Element]()
    internal var cells = [EasyListContentView: UITableViewCell]()
    internal var onBatchUpdate = false
    internal var batchUpdateOption: EasyListUpdateOption = .animatedLayout
    
    @objc(initWithScrollView:)
    public init(with scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
}
