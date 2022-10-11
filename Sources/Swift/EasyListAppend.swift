//
//  EasyListAppend.swift
//  EasyListViewExample
//
//  Created by carefree on 2022/10/7.
//  Copyright © 2022 carefree. All rights reserved.
//

import UIKit
import EasyCompatible

public extension EasyExtension where Base: UIScrollView {
    /**
     添加一个视图元素
     
     * parameter viewClosure: 视图闭包
     
     * returns: 自定义配置项
     */
    @discardableResult
    func appendView(_ viewClosure: () -> UIView) -> EasyListAttributes {
        return appendView(viewClosure())
    }
    
    /**
     添加一个视图元素
     
     * parameter view: 视图
     
     * returns: 自定义配置项
     */
    @discardableResult
    func appendView(_ view: UIView) -> EasyListAttributes {
        let scrollView = base
        
        //移除旧的约束
        searchConstraintsIn(scrollView, with: [
            .first(scrollView, .bottom),
            .second(scrollView, .bottom)
        ]).forEach { $0.isActive = false }
        //添加子视图
        var contentView = EasyListContentView()
        var isDisposable = false
        if let disposableView = view as? EasyListContentView {
            //动态元素
            contentView = disposableView
            isDisposable = true
        } else {
            //静态元素
            var staticView = view
            if let cell = staticView as? UITableViewCell {
                staticView = cell.contentView
                coordinator.cells[contentView] = cell
            }
            staticView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(staticView)
        }
        
        guard let view = contentView.subviews.first else {
            return EasyListAttributes()
        }
        
        var insets = coordinator.globalEdgeInsets
        insets.top = insets.top + coordinator.globalSpacing
        
        let leadingConstraint = addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading, constant: insets.left)
        let trailingConstraint = addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing, constant: -insets.right)
        let topConstraint = addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top, constant: insets.top)
        let bottomConstraint = addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom, constant: -insets.bottom)
        
        contentView.clipsToBounds = coordinator.globalClipsToBounds
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        addConstraint(for: scrollView, item1: scrollView, attr1: .width, item2: contentView, attr2: .width)
        addConstraint(for: scrollView, item1: contentView, attr1: .leading, item2: scrollView, attr2: .leading)
        addConstraint(for: scrollView, item1: contentView, attr1: .trailing, item2: scrollView, attr2: .trailing)
        addConstraint(for: scrollView, item1: contentView, attr1: .bottom, item2: scrollView, attr2: .bottom)
        if let lastView = coordinator.elements.last?.view {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: lastView, attr2: .bottom)
        } else {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: scrollView, attr2: .top)
        }
        
        var element = Element(view: contentView, insets: insets)
        coordinator.elements.append(element)
        if isDisposable {
            coordinator.disposableElements.append(Element(view: contentView, insets: insets))
        }
        
        if coordinator.onBatchUpdate {
            element.inserting = true
        }
        
        var attributes = EasyListAttributes()
        attributes.coordinator = coordinator
        attributes.element = element
        attributes.leadingConstraint = leadingConstraint
        attributes.trailingConstraint = trailingConstraint
        attributes.topConstraint = topConstraint
        attributes.bottomConstraint = bottomConstraint
        
        return attributes
    }
}
