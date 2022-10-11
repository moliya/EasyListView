//
//  EasyListAttributes.swift
//  EasyListView
//
//  Created by carefree on 2022/10/9.
//

import UIKit

public struct EasyListAttributes {
    internal var coordinator: EasyListCoordinator?
    internal var element: Element?
    internal var leadingConstraint: NSLayoutConstraint?
    internal var trailingConstraint: NSLayoutConstraint?
    internal var topConstraint: NSLayoutConstraint?
    internal var bottomConstraint: NSLayoutConstraint?
}

public extension EasyListAttributes {
    /**
     设置唯一标识
     
     * parameter identifier: 标识字符串
     
     * returns: 自定义配置项
     */
    @discardableResult
    func identifier(_ identifier: String) -> Self {
        if let coordinator = coordinator, let element = element {
            if let index = coordinator.elements.firstIndex(of: element) {
                var newElement = coordinator.elements[index]
                newElement.identifier = identifier
                coordinator.elements[index] = newElement
            }
            if let index = coordinator.disposableElements.firstIndex(of: element) {
                var newElement = coordinator.elements[index]
                newElement.identifier = identifier
                coordinator.elements[index] = newElement
            }
        }
        
        return self
    }
    
    /**
     设置内间距
     
     * parameter insets: 内间距
     
     * returns: 自定义配置项
     */
    @discardableResult
    func insets(_ insets: UIEdgeInsets) -> Self {
        leadingConstraint?.constant = insets.left
        trailingConstraint?.constant = -insets.right
        topConstraint?.constant = insets.top
        bottomConstraint?.constant = -insets.bottom
        return self
    }
    
    /**
     设置与上一元素的间距
     
     * parameter spacing: 间距
     
     * returns: 自定义配置项
     */
    @discardableResult
    func spacing(_ spacing: CGFloat) -> Self {
        topConstraint?.constant = spacing
        return self
    }
    
    /**
     设置超出部分是否裁剪
     
     * parameter clipsToBounds: 是否裁剪
     
     * returns: 自定义配置项
     */
    @discardableResult
    func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        element?.view.clipsToBounds = clipsToBounds
        return self
    }
}
