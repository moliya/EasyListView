//
//  EasyListConstraint.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/6.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

// 添加约束
@discardableResult
internal func addConstraint(for view: UIView,
                            item1: AnyObject,
                            attr1: NSLayoutConstraint.Attribute,
                            item2: AnyObject? = nil,
                            attr2: NSLayoutConstraint.Attribute? = nil,
                            constant: CGFloat = 0) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(
        item: item1,
        attribute: attr1,
        relatedBy: .equal,
        toItem: item2,
        attribute: ((attr2 == nil) ? attr1 : attr2! ),
        multiplier: 1,
        constant: constant
    )
    c.priority = UILayoutPriority(rawValue: UILayoutPriority.defaultHigh.rawValue + 1)
    view.addConstraint(c)
    return c
}
