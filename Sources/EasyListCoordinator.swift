//
//  EasyListCoordinator.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/8.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

@objcMembers
open class EasyListCoordinator: NSObject {
    
    internal struct Element {
        var view: UIView
        var identifier: String?
        var deleting: Bool = false
        var remainSpacing: CGFloat = 0
        var maker: (() -> UIView)? = nil
    }
    
    public weak private(set) var scrollView: UIScrollView?
    
    //全局内边距
    public var globalEdgeInsets: UIEdgeInsets = .zero
    //全局元素间距
    public var globalSpacing: CGFloat = 0
    //动画持续时间（包括插入、删除），为0则无动画
    public var animationDuration: TimeInterval = 0.3
    
    internal var elements = [Element]()
    internal var reusableElements = [Element]()
    internal var cells = [UITableViewCell]()
    internal var onBatchUpdate = false
    
    @objc(initWithScrollView:)
    public init(with scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
}
