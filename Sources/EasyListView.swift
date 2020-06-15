//
//  EasyListView.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/6/11.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

open class EasyListViewCoordinator {
    
    public struct Element {
        var view: UIView
        var identifier: String?
        var deleting: Bool = false
        var remainSpacing: CGFloat = 0
    }
    
    weak private(set) var scrollView: UIScrollView?
    
    //全局内边距
    public var globalEdgeInsets: UIEdgeInsets = .zero
    //全局元素间距
    public var globalSpacing: CGFloat = 0
    //动画持续时间（包括插入、删除），为0则无动画
    public var animationDuration: TimeInterval = 0.3
    
    fileprivate var elements = [Element]()
    fileprivate var onBatchUpdate = false
    
    public init(with scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
}

private var EasyListViewCoordinatorKey = "EasyListViewCoordinatorKey"
//添加easy扩展
extension UIScrollView: EasyListCompatible { }
public extension EasyListExtension where Base: UIScrollView {
    
    // MARK: - Coordinator
    var coordinator: EasyListViewCoordinator {
        get {
            if let coordinator = objc_getAssociatedObject(self.base, &EasyListViewCoordinatorKey) as? EasyListViewCoordinator {
                return coordinator
            }
            let coordinator = EasyListViewCoordinator(with: self.base)
            objc_setAssociatedObject(self.base, &EasyListViewCoordinatorKey, coordinator, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return coordinator
        }
        set {
            objc_setAssociatedObject(self.base, &EasyListViewCoordinatorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Append
    /**
    添加一个视图元素
    
    * parameter view: 要添加的视图
    */
    func append(_ view: UIView) {
        var inset = coordinator.globalEdgeInsets
        if coordinator.elements.count > 0 {
            inset.top = coordinator.globalSpacing
        }
        append(view, with: inset)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 要添加的视图
    * parameter spacing: 与上一个视图的间距
    */
    func append(_ view: UIView, spacing: CGFloat) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(view, with: inset)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 要添加的视图
    * parameter identifier: 视图唯一标识
    * parameter spacing: 与上一个视图的间距
    */
    func append(_ view: UIView, for identifier: String = "", spacing: CGFloat = 0) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(view, with: inset, for: identifier)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 要添加的视图
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    */
    func append(_ view: UIView, with insets: UIEdgeInsets, for identifier: String = "") {
        let scrollView = base
        
        //移除旧的约束
        for constraint in scrollView.constraints {
            if constraint.firstAttribute == .bottom {
                if let first = constraint.firstItem as? UIScrollView, first == scrollView {
                    constraint.isActive = false
                    break
                }
            }
            if constraint.secondAttribute == .bottom {
                if let second = constraint.secondItem as? UIScrollView, second == scrollView {
                    constraint.isActive = false
                    break
                }
            }
        }
        //添加子视图
        let contentView = UIView()
        contentView.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        
        scrollView.addSubview(contentView)
        addConstraint(for: scrollView, item1: scrollView, attr1: .width, item2: contentView, attr2: .width, constant: insets.left + insets.right)
        addConstraint(for: scrollView, item1: contentView, attr1: .leading, item2: scrollView, attr2: .leading, constant: insets.left)
        addConstraint(for: scrollView, item1: contentView, attr1: .trailing, item2: scrollView, attr2: .trailing, constant: -insets.right)
        addConstraint(for: scrollView, item1: contentView, attr1: .bottom, item2: scrollView, attr2: .bottom, constant: -insets.bottom)
        if let lastView = coordinator.elements.last?.view {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: lastView, attr2: .bottom, constant: insets.top)
        } else {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: scrollView, attr2: .top, constant: insets.top)
        }
        
        coordinator.elements.append(EasyListViewCoordinator.Element(view: contentView, identifier: identifier))
    }
    
    // MARK: - Insert
    /**
    插入一个视图元素
    
    * parameter view: 要插入的视图
    * parameter element: 前一个视图元素，可以是UIView，也可以是视图唯一标识
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    * parameter completion: 插入完成回调
    */
    func insert(_ view: UIView, after element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> ())? = nil) {
        let scrollView = base
        let duration = coordinator.animationDuration
        let elements = coordinator.elements
        
        var relateIdentifier: String?
        if let string = element as? String  {
            relateIdentifier = elements.first { $0.identifier == string }?.identifier
        }
        if let view = element as? UIView {
            if view == scrollView {
                relateIdentifier = "super"
            } else {
                relateIdentifier = elements.first { $0.view == view }?.identifier
            }
        }
        assert(relateIdentifier != nil, "invalid element")
        
        var previousView: UIView?
        var nextView: UIView = scrollView
        var flag = false
        var index = -1
        if relateIdentifier == "super" {
            previousView = scrollView
            flag = true
            index = 0
        }
        for i in 0 ..< elements.count {
            if elements[i].identifier == relateIdentifier {
                previousView = elements[i].view
                flag = true
                index = i + 1
                continue
            } else if flag {
                nextView = elements[i].view
                break
            }
        }
        
        //移除旧的约束
        for constraint in scrollView.constraints {
            if let first = constraint.firstItem as? UIView, first == previousView,
                let second = constraint.secondItem as? UIView, second == nextView {
                constraint.isActive = false
                break
            }
            if let first = constraint.firstItem as? UIView, first == nextView,
                let second = constraint.secondItem as? UIView, second == previousView {
                constraint.isActive = false
                break
            }
        }
        //插入子视图
        let contentView = UIView()
        contentView.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        let heightConstraint = addConstraint(for: contentView, item1: contentView, attr1: .height, item2: nil, attr2: .notAnAttribute)
        
        scrollView.addSubview(contentView)
        addConstraint(for: scrollView, item1: scrollView, attr1: .width, item2: contentView, attr2: .width, constant: insets.left + insets.right)
        addConstraint(for: scrollView, item1: contentView, attr1: .leading, item2: scrollView, attr2: .leading, constant: insets.left)
        addConstraint(for: scrollView, item1: contentView, attr1: .trailing, item2: scrollView, attr2: .trailing, constant: -insets.right)
        if previousView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .top, constant: insets.top)
        } else {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .bottom, constant: insets.top)
        }
        if nextView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .bottom, item2: nextView, attr2: .bottom, constant: -insets.bottom)
        } else {
            addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: contentView, attr2: .bottom, constant: insets.bottom)
        }
        //更新contentView约束
        let updateClosure = {
            //删除height约束
            contentView.constraints.first { $0.firstAttribute == .height }?.isActive = false
            //添加bottom约束
            self.addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        }
        
        //添加元素
        coordinator.elements.insert(EasyListViewCoordinator.Element(view: contentView, identifier: identifier), at: index)
        //更新布局
        UIView.animate(withDuration: duration * 1 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            //更新高度约束
            heightConstraint.constant = view.frame.size.height
            UIView.animate(withDuration: duration * 3 / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                updateClosure()
                completion?()
            }
        }
    }
    
    /**
    插入一个视图元素
    
    * parameter view: 要插入的视图
    * parameter element: 后一个视图元素，可以是UIView，也可以是视图唯一标识
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    * parameter completion: 插入完成回调
    */
    func insert(_ view: UIView, before element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> ())? = nil) {
        let scrollView = base
        let duration = coordinator.animationDuration
        let elements = coordinator.elements
        
        var relateIdentifier: String?
        if let string = element as? String  {
            relateIdentifier = elements.first { $0.identifier == string }?.identifier
        }
        if let view = element as? UIView {
            if view == scrollView {
                relateIdentifier = "super"
            } else {
                relateIdentifier = elements.first { $0.view == view }?.identifier
            }
        }
        assert(relateIdentifier != nil, "invalid element")
        
        var previousView: UIView = scrollView
        var nextView: UIView?
        var flag = false
        var index = -1
        if relateIdentifier == "super" {
            nextView = scrollView
            flag = true
            index = elements.count
        }
        for i in (0 ..< elements.count).reversed() {
            if elements[i].identifier == relateIdentifier {
                nextView = elements[i].view
                flag = true
                index = i
                continue
            } else if flag {
                previousView = elements[i].view
                break
            }
        }
        
        //移除旧的约束
        for constraint in scrollView.constraints {
            if let first = constraint.firstItem as? UIView, first == previousView,
                let second = constraint.secondItem as? UIView, second == nextView {
                constraint.isActive = false
                break
            }
            if let first = constraint.firstItem as? UIView, first == nextView,
                let second = constraint.secondItem as? UIView, second == previousView {
                constraint.isActive = false
                break
            }
        }
        //插入子视图
        let contentView = UIView()
        contentView.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        let heightConstraint = addConstraint(for: contentView, item1: contentView, attr1: .height, item2: nil, attr2: .notAnAttribute)
        
        scrollView.addSubview(contentView)
        addConstraint(for: scrollView, item1: scrollView, attr1: .width, item2: contentView, attr2: .width, constant: insets.left + insets.right)
        addConstraint(for: scrollView, item1: contentView, attr1: .leading, item2: scrollView, attr2: .leading, constant: insets.left)
        addConstraint(for: scrollView, item1: contentView, attr1: .trailing, item2: scrollView, attr2: .trailing, constant: -insets.right)
        if previousView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .top, constant: insets.top)
        } else {
            addConstraint(for: scrollView, item1: contentView, attr1: .top, item2: previousView, attr2: .bottom, constant: insets.top)
        }
        if nextView == scrollView {
            addConstraint(for: scrollView, item1: contentView, attr1: .bottom, item2: nextView, attr2: .bottom, constant: -insets.bottom)
        } else {
            addConstraint(for: scrollView, item1: nextView!, attr1: .top, item2: contentView, attr2: .bottom, constant: insets.bottom)
        }
        //更新contentView约束
        let updateClosure = {
            //删除height约束
            contentView.constraints.first { $0.firstAttribute == .height }?.isActive = false
            //添加bottom约束
            self.addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        }
        
        //添加元素
        coordinator.elements.insert(EasyListViewCoordinator.Element(view: contentView, identifier: identifier), at: index)
        //更新布局
        UIView.animate(withDuration: duration * 1 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            //更新高度约束
            heightConstraint.constant = view.frame.size.height
            UIView.animate(withDuration: duration * 3 / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                updateClosure()
                completion?()
            }
        }
    }
    
    // MARK: - Delete
    /**
    删除一个视图元素
    
    * parameter element: 要删除的视图，可以是UIView，也可以是视图的唯一标识
    * parameter spacing: 视图移除后留下的上下间距
    * parameter completion: 删除完成后的回调
    */
    func delete(_ element: Any, remainSpacing spacing: CGFloat = 0, completion: (() -> ())? = nil) {
        let elements = coordinator.elements
        
        var identifier: String?
        if let string = element as? String  {
            identifier = elements.first { $0.identifier == string }?.identifier
        }
        if let view = element as? UIView {
            identifier = elements.first { $0.view == view }?.identifier
        }
        assert(identifier != nil, "invalid element")
        
        for i in 0 ..< coordinator.elements.count {
            if identifier == coordinator.elements[i].identifier {
                if !coordinator.elements[i].deleting {
                    coordinator.elements[i].deleting = true
                    coordinator.elements[i].remainSpacing = spacing
                    break
                }
            }
        }
        
        if coordinator.onBatchUpdate {
            return
        }
        
        applyDeletion {
            completion?()
        }
    }
    
    /**
    批量删除视图元素
    
    * parameter deleteClosure: 在该闭包中调用delete方法来标记待删除的视图元素
    * parameter completion: 删除完成后的回调
    */
    func batchDelete(deleteClosure: (UIScrollView) -> (), completion: (() -> ())?) {
        coordinator.onBatchUpdate = true
        deleteClosure(base)
        coordinator.onBatchUpdate = false
        
        applyDeletion {
            completion?()
        }
    }
    
    /**
    删除所有视图元素
     
    */
    func deleteAll() {
        coordinator.elements.forEach {
            $0.view.removeFromSuperview()
        }
        coordinator.elements.removeAll()
    }
    
    // MARK: - Getter
    /**
    获取视图元素
    
    * parameter identifier: 视图唯一标识
     
    * returns: 找到的视图
    */
    func getElement(identifier: String) -> UIView? {
        return coordinator.elements.first { $0.identifier == identifier }?.view.subviews.first
    }
    
    // MARK: - Private
    // 执行删除逻辑
    private func applyDeletion(completion: (() -> ())? = nil) {
        let scrollView = base
        let duration = coordinator.animationDuration
        let elements = coordinator.elements
        
        var list = [(UIView, UIView, CGFloat)]()
        var previousView: UIView = scrollView
        var nextView: UIView?
        var flag = false
        var spacing: CGFloat = 0
        for element in elements {
            if element.deleting {
                spacing += element.remainSpacing
                flag = true
                continue
            }
            if flag {
                nextView = element.view
            } else {
                previousView = element.view
            }
            if let view = nextView {
                list.append((previousView, view, spacing))
                
                previousView = element.view
                nextView = nil
                flag = false
                spacing = 0
            }
        }
        if flag {
            list.append((previousView, scrollView, spacing))
        }
        if list.count == 0 {
            completion?()
            return
        }
        
        //替换bottom约束为高度约束
        let deletingViews = elements.filter { $0.deleting }.map { $0.view }
        for view in deletingViews {
            let height = view.frame.size.height
            view.constraints.forEach {
                if let item = $0.firstItem as? UIView, item == view && $0.firstAttribute == .bottom {
                    $0.isActive = false
                }
                if let item = $0.secondItem as? UIView, item == view && $0.secondAttribute == .bottom {
                    $0.isActive = false
                }
            }
            let heightConstraint = addConstraint(for: view, item1: view, attr1: .height, item2: nil, attr2: .notAnAttribute, constant: height)
            view.layoutIfNeeded()
            
            heightConstraint.constant = 0
        }
        //添加新的约束
        let updateClosure = {
            for (previousView, nextView, remainSpacing) in list {
                if previousView == nextView {
                    continue
                }
                if previousView == scrollView {
                    self.addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .top, constant: remainSpacing)
                } else if nextView == scrollView {
                    self.addConstraint(for: scrollView, item1: nextView, attr1: .bottom, item2: previousView, attr2: .bottom, constant: remainSpacing)
                } else {
                    self.addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .bottom, constant: remainSpacing)
                }
            }
        }
        
        //更新布局
        UIView.animate(withDuration: duration * 3 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            updateClosure()
            UIView.animate(withDuration: duration / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                //完成后移除相关元素
                deletingViews.forEach { $0.removeFromSuperview() }
                self.coordinator.elements.removeAll { $0.deleting }
                completion?()
            }
        }
    }
    
    // 添加约束
    @discardableResult
    private func addConstraint(for view: UIView,
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
}
