//
//  EasyListInsertDeprecated.swift
//  EasyListViewExample
//
//  Created by carefree on 2022/10/7.
//  Copyright © 2022 carefree. All rights reserved.
//

import UIKit
import EasyCompatible

public extension EasyExtension where Base: UIScrollView {
    /**
     插入一个视图元素
     
     * parameter viewOrClosure: 视图或闭包
     * parameter element: 前一个视图元素，可以是UIView，也可以是视图唯一标识
     * parameter insets: 视图自定义的间距
     * parameter identifier: 视图唯一标识
     * parameter completion: 插入完成回调
     */
    @available(*, deprecated, renamed: "insertView(_:after:)", message: "Please use insertView(_:after:) instead.")
    func insert(_ viewOrClosure: Any, after element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> Void)? = nil) {
        let scrollView = base
        let elements = coordinator.elements
        
        var relateView: UIView?
        if let string = element as? String {
            relateView = elements.first { $0.identifier == string }?.view
        }
        if let cell = element as? UITableViewCell {
            relateView = coordinator.cells.first { $0.value == cell }?.key
        } else if let view = element as? UIView {
            if view == scrollView {
                relateView = view
            } else {
                relateView = elements.first { $0.view == view.superview }?.view
            }
        }
        assert(relateView != nil, "invalid element")
        
        //查找前后视图及下标
        var previousView: UIView?
        var nextView: UIView = scrollView
        var flag = false
        var index = -1
        if relateView == scrollView {
            previousView = scrollView
            flag = true
            index = 0
        }
        for i in 0 ..< elements.count {
            if elements[i].view == relateView {
                previousView = elements[i].view
                flag = true
                index = i + 1
                continue
            } else if flag {
                nextView = elements[i].view
                break
            }
        }
        
        insert(viewOrClosure, previousView: previousView, nextView: nextView, index: index, with: insets, for: identifier, completion: completion)
    }
    
    /**
     插入一个视图元素
     
     * parameter viewOrClosure: 视图或闭包
     * parameter element: 后一个视图元素，可以是UIView，也可以是视图唯一标识
     * parameter insets: 视图自定义的间距
     * parameter identifier: 视图唯一标识
     * parameter completion: 插入完成回调
     */
    @available(*, deprecated, renamed: "insertView(_:before:)", message: "Please use insertView(_:before:) instead.")
    func insert(_ viewOrClosure: Any, before element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> Void)? = nil) {
        let scrollView = base
        let elements = coordinator.elements
        
        var relateView: UIView?
        if let string = element as? String {
            relateView = elements.first { $0.identifier == string }?.view
        }
        if let cell = element as? UITableViewCell {
            relateView = coordinator.cells.first { $0.value == cell }?.key
        } else if let view = element as? UIView {
            if view == scrollView {
                relateView = view
            } else {
                relateView = elements.first { $0.view == view.superview }?.view
            }
        }
        assert(relateView != nil, "invalid element")
        
        //查找前后视图及下标
        var previousView: UIView = scrollView
        var nextView: UIView?
        var flag = false
        var index = -1
        if relateView == scrollView {
            nextView = scrollView
            flag = true
            index = elements.count
        }
        for i in (0 ..< elements.count).reversed() {
            if elements[i].view == relateView {
                nextView = elements[i].view
                flag = true
                index = i
                continue
            } else if flag {
                previousView = elements[i].view
                break
            }
        }
        
        insert(viewOrClosure, previousView: previousView, nextView: nextView, index: index, with: insets, for: identifier, completion: completion)
    }
    
    /**
     插入一个视图元素
     
     * parameter viewOrClosure: 视图或闭包
     * parameter previousView: 前一个视图元素
     * parameter nextView: 后一个视图元素
     * parameter index: 插入的下标
     * parameter insets: 视图自定义的间距
     * parameter identifier: 视图唯一标识
     * parameter completion: 插入完成回调
     */
    private func insert(_ viewOrClosure: Any, previousView: UIView?, nextView: UIView?, index: Int, with insets: UIEdgeInsets, for identifier: String, completion: (() -> Void)?) {
        let scrollView = base
        
        //移除旧的约束
        searchConstraintsIn(scrollView, with: [
            .both(previousView, .top, nextView, .top),
            .both(previousView, .top, nextView, .bottom),
            .both(previousView, .bottom, nextView, .top),
            .both(previousView, .bottom, nextView, .bottom),
            .both(nextView, .top, previousView, .top),
            .both(nextView, .top, previousView, .bottom),
            .both(nextView, .bottom, previousView, .top),
            .both(nextView, .bottom, previousView, .bottom)
        ]).forEach { $0.isActive = false }
        //插入子视图
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
        if previousView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .top)
        } else {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .bottom)
        }
        if nextView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .bottom, item2: nextView, attr2: .bottom)
        } else {
            addConstraint(for: scrollView, item1: nextView!, attr1: .top, item2: contentView, attr2: .bottom)
        }
        
        var element = Element(view: contentView, insets: insets, identifier: identifier)
        element.inserting = true
        coordinator.elements.insert(element, at: index)
        if isDisposable {
            var disposableIndex = 0
            for tmp in coordinator.disposableElements {
                for i in 0 ..< index {
                    if tmp.view == coordinator.elements[i].view {
                        disposableIndex += 1
                    }
                }
            }
            coordinator.disposableElements.insert(Element(view: contentView, insets: insets, identifier: identifier), at: disposableIndex)
        }
        
        if coordinator.onBatchUpdate {
            completion?()
            return
        }
        
        animateInsertion(completion: {
            self.reloadDisposableIfNeed()
            completion?()
        }, duration: coordinator.animationDuration)
    }
}
