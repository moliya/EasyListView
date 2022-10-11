//
//  EasyListAppendDeprecated.swift
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
     
     * parameter viewOrClosure: 视图或闭包
     * parameter spacing: 与上一个视图的间距
     */
    @available(*, deprecated, renamed: "appendView(_:)", message: "Please use appendView(_:) instead.")
    func append(_ viewOrClosure: Any, spacing: CGFloat = 0) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(viewOrClosure, with: inset)
    }
    
    /**
     添加一个视图元素
     
     * parameter viewOrClosure: 视图或闭包
     * parameter identifier: 视图唯一标识
     * parameter spacing: 与上一个视图的间距
     */
    @available(*, deprecated, renamed: "appendView(_:)", message: "Please use appendView(_:) instead.")
    func append(_ viewOrClosure: Any, for identifier: String = "", spacing: CGFloat = 0) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(viewOrClosure, with: inset, for: identifier)
    }
    
    /**
     添加一个视图元素
     
     * parameter viewOrClosure: 视图或闭包
     * parameter insets: 视图自定义的间距
     * parameter identifier: 视图唯一标识
     */
    @available(*, deprecated, renamed: "appendView(_:)", message: "Please use appendView(_:) instead.")
    func append(_ viewOrClosure: Any, with insets: UIEdgeInsets, for identifier: String = "") {
        let scrollView = base
        
        //移除旧的约束
        searchConstraintsIn(scrollView, with: [
            .first(scrollView, .bottom),
            .second(scrollView, .bottom)
        ]).forEach { $0.isActive = false }
        //添加子视图
        var contentView = EasyListContentView()
        var isDisposable = false
        if let disposableView = viewOrClosure as? EasyListContentView {
            //动态元素
            contentView = disposableView
            isDisposable = true
        } else if let staticView = viewOrClosure as? UIView {
            //静态元素
            var view = staticView
            if let cell = view as? UITableViewCell {
                view = cell.contentView
                coordinator.cells[contentView] = cell
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        } else if let closure = viewOrClosure as? () -> UIView {
            //闭包
            var view = closure()
            if let cell = view as? UITableViewCell {
                view = cell.contentView
                coordinator.cells[contentView] = cell
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        guard let view = contentView.subviews.first else { return }
        
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading, constant: insets.left)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing, constant: -insets.right)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top, constant: insets.top)
        addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom, constant: -insets.bottom)
        
        contentView.clipsToBounds = true
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
        
        var element = Element(view: contentView, insets: insets, identifier: identifier)
        coordinator.elements.append(element)
        if isDisposable {
            coordinator.disposableElements.append(Element(view: contentView, insets: insets, identifier: identifier))
        }
        
        if coordinator.onBatchUpdate {
            element.inserting = true
        }
    }
}
