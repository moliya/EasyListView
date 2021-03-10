//
//  EasyListExtension.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/8.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

private var EasyListCoordinatorKey = "EasyListCoordinatorKey"
//添加easy扩展
extension UIScrollView: EasyListCompatible { }

public extension EasyListExtension where Base: UIScrollView {
    
    typealias ViewOrClosure = Any
    
    // MARK: - Coordinator
    var coordinator: EasyListCoordinator {
        get {
            if let coordinator = objc_getAssociatedObject(self.base, &EasyListCoordinatorKey) as? EasyListCoordinator {
                return coordinator
            }
            let coordinator = EasyListCoordinator(with: self.base)
            objc_setAssociatedObject(self.base, &EasyListCoordinatorKey, coordinator, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return coordinator
        }
        set {
            objc_setAssociatedObject(self.base, &EasyListCoordinatorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Append
    /**
    添加一个视图元素
    
    * parameter view: 视图或闭包
    */
    func append(_ view: ViewOrClosure) {
        var inset = coordinator.globalEdgeInsets
        if coordinator.elements.count > 0 {
            inset.top = coordinator.globalSpacing
        }
        append(view, with: inset)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 视图或闭包
    * parameter spacing: 与上一个视图的间距
    */
    func append(_ view: ViewOrClosure, spacing: CGFloat) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(view, with: inset)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 视图或闭包
    * parameter identifier: 视图唯一标识
    * parameter spacing: 与上一个视图的间距
    */
    func append(_ view: ViewOrClosure, for identifier: String = "", spacing: CGFloat = 0) {
        var inset = coordinator.globalEdgeInsets
        inset.top = spacing
        append(view, with: inset, for: identifier)
    }
    
    /**
    添加一个视图元素
    
    * parameter view: 视图或闭包
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    */
    func append(_ view: ViewOrClosure, with insets: UIEdgeInsets, for identifier: String = "") {
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
        var contentView = EasyListContentView()
        if let disposableView = view as? EasyListContentView {
            //动态元素
            contentView = disposableView
            coordinator.disposableElements.append(EasyListCoordinator.Element(view: contentView))
        } else if let staticView = view as? UIView {
            //静态元素
            var view = staticView
            if let cell = view as? UITableViewCell {
                view = cell.contentView
                coordinator.cells[contentView] = cell
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        } else if let closure = view as? () -> UIView {
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
        
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
        
        coordinator.elements.append(EasyListCoordinator.Element(view: contentView, identifier: identifier))
    }
    
    // MARK: - Insert
    /**
    插入一个视图元素
    
    * parameter view: 视图或闭包
    * parameter element: 前一个视图元素，可以是UIView，也可以是视图唯一标识
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    * parameter completion: 插入完成回调
    */
    func insert(_ view: ViewOrClosure, after element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> Void)? = nil) {
        let scrollView = base
        let duration = coordinator.animationDuration
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
        var contentView = EasyListContentView()
        var isDisposable = false
        if let disposableView = view as? EasyListContentView {
            //动态元素
            contentView = disposableView
            isDisposable = true
        } else if let staticView = view as? UIView {
            //静态元素
            var view = staticView
            if let cell = view as? UITableViewCell {
                view = cell.contentView
                coordinator.cells[contentView] = cell
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        } else if let closure = view as? () -> UIView {
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
        
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        let heightConstraint = addConstraint(for: contentView, item1: contentView, attr1: .height, item2: nil, attr2: .notAnAttribute)
        
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
            addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        }
        
        coordinator.elements.insert(EasyListCoordinator.Element(view: contentView, identifier: identifier), at: index)
        //更新布局
        UIView.animate(withDuration: duration * 1 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            if isDisposable {
                let minY = contentView.frame.minY
                var index = 0
                for tmp in self.coordinator.disposableElements {
                    if tmp.view.frame.minY > minY {
                        break
                    }
                    index += 1
                }
                self.coordinator.disposableElements.insert(EasyListCoordinator.Element(view: contentView), at: index)
            }
            //更新高度约束
            heightConstraint.constant = view.frame.size.height
            UIView.animate(withDuration: duration * 3 / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                self.reloadDisposableIfNeed()
                updateClosure()
                completion?()
            }
        }
    }
    
    /**
    插入一个视图元素
    
    * parameter view: 视图或闭包
    * parameter element: 后一个视图元素，可以是UIView，也可以是视图唯一标识
    * parameter insets: 视图自定义的间距
    * parameter identifier: 视图唯一标识
    * parameter completion: 插入完成回调
    */
    func insert(_ view: ViewOrClosure, before element: Any, with insets: UIEdgeInsets = .zero, for identifier: String = "", completion: (() -> Void)? = nil) {
        let scrollView = base
        let duration = coordinator.animationDuration
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
        var contentView = EasyListContentView()
        var isDisposable = false
        if let disposableView = view as? EasyListContentView {
            //动态元素
            contentView = disposableView
            isDisposable = true
        } else if let staticView = view as? UIView {
            //静态元素
            var view = staticView
            if let cell = view as? UITableViewCell {
                view = cell.contentView
                coordinator.cells[contentView] = cell
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        } else if let closure = view as? () -> UIView {
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
        
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        let heightConstraint = addConstraint(for: contentView, item1: contentView, attr1: .height, item2: nil, attr2: .notAnAttribute)
        
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
            addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        }
        
        coordinator.elements.insert(EasyListCoordinator.Element(view: contentView, identifier: identifier), at: index)
        //更新布局
        UIView.animate(withDuration: duration * 1 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            if isDisposable {
                let minY = contentView.frame.minY
                var index = 0
                for tmp in self.coordinator.disposableElements {
                    if tmp.view.frame.minY > minY {
                        break
                    }
                    index += 1
                }
                self.coordinator.disposableElements.insert(EasyListCoordinator.Element(view: contentView), at: index)
            }
            //更新高度约束
            heightConstraint.constant = view.frame.size.height
            UIView.animate(withDuration: duration * 3 / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                self.reloadDisposableIfNeed()
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
    func delete(_ element: Any, remainSpacing spacing: CGFloat = 0, completion: (() -> Void)? = nil) {
        let elements = coordinator.elements
        
        var targetView: UIView?
        if let string = element as? String {
            targetView = elements.first { $0.identifier == string }?.view
        }
        if let cell = element as? UITableViewCell {
            targetView = coordinator.cells.first { $0.value == cell }?.key
        } else if let view = element as? UIView {
            targetView = elements.first { $0.view == view.superview }?.view
        }
        assert(targetView != nil, "invalid element")
        
        for i in 0 ..< coordinator.elements.count {
            if targetView == coordinator.elements[i].view {
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
            self.reloadDisposableIfNeed()
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
        coordinator.disposableElements.removeAll()
    }
    
    // MARK: - BatchUpdate
    /**
    开始批量更新操作
    
    * Note: 需和endUpdates成对使用。批量更新操作包括append(添加)和delete(删除)
    */
    func beginUpdates() {
        coordinator.onBatchUpdate = true
    }
    
    /**
    完成批量更新操作
     
    * parameter completion: 更新完成后的回调
    */
    func endUpdates(_ completion: (() -> Void)? = nil) {
        coordinator.onBatchUpdate = false
        
        //是否有删除元素
        let count = coordinator.elements.filter { $0.deleting }.count
        if count > 0 {
            //执行删除操作
            applyDeletion {
                self.reloadDisposableIfNeed()
                completion?()
            }
        } else {
            //不执行删除操作
            base.layoutIfNeeded()
            self.reloadDisposableIfNeed()
            completion?()
        }
    }
    
    // MARK: - Disposable
    /**
    生成自释放元素
    
    * parameter maker: 闭包
     
    * returns: 生成的视图
    */
    func disposableView(with maker: @escaping () -> UIView) -> UIView {
        let contentView = EasyListContentView()
        var view = maker()
        if let cell = view as? UITableViewCell {
            view = cell.contentView
            coordinator.cells[contentView] = cell
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        contentView.disposableMaker = maker
        
        return contentView
    }
    
    /**
    刷新数据
     
    */
    func reloadDisposableData() {
        coordinator.disposableElements.forEach {
            $0.view.subviews.first?.removeFromSuperview()
        }
        reloadDisposableIfNeed()
    }
    
    /**
    触发自释放机制
     
    */
    func triggerDisposable() {
        let scrollView = base
        
        let offset = scrollView.contentOffset.y
        let range = scrollView.frame.height
        let minY = offset - range
        let maxY = offset + range + range
        
        coordinator.disposableElements.forEach { element in
            let contentView = element.view
            let frame = contentView.frame
            guard let maker = contentView.disposableMaker else { return }
            
            if frame.maxY >= minY && frame.minY <= maxY {
                //在可视范围内
                if contentView.subviews.count == 0 {
                    //恢复子视图
                    var view = maker()
                    if let cell = view as? UITableViewCell {
                        view = cell.contentView
                        coordinator.cells[contentView] = cell
                    }
                    view.translatesAutoresizingMaskIntoConstraints = false
                    contentView.addSubview(view)
                    addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
                    addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
                    addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
                    addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
                    //删除height约束
                    contentView.constraints.first { $0.firstAttribute == .height }?.isActive = false
                }
            } else {
                //不在可视范围内
                if contentView.subviews.count > 0 {
                    //移除子视图，回收内存
                    addConstraint(for: contentView, item1: contentView, attr1: .height, item2: nil, attr2: .notAnAttribute, constant: frame.height)
                    coordinator.cells.removeValue(forKey: contentView)
                    contentView.subviews.forEach { $0.removeFromSuperview() }
                }
            }
        }
    }
    
    // MARK: - Getter
    /**
    获取视图元素
    
    * parameter identifier: 视图唯一标识
     
    * returns: 找到的视图
    */
    func getElement(identifier: String) -> UIView? {
        let getView = coordinator.elements.first { $0.identifier == identifier }?.view
        guard let contentView = getView else {
            return nil
        }
        if let cell = coordinator.cells[contentView] {
            return cell
        }
        return contentView.subviews.first
    }
    
    /**
    获取指定下标的自释放元素
    
    * parameter index: 下标
     
    * returns: 找到的视图
    */
    func getDisposableElement(at index: Int) -> UIView? {
        if index >= coordinator.disposableElements.count {
            return nil
        }
        let contentView = coordinator.disposableElements[index].view
        if let cell = coordinator.cells[contentView] {
            return cell
        }
        return contentView.subviews.first
    }
    
    /**
    获取所有可视的自释放元素
     
    * returns: 找到的视图集合
    */
    var visibleDisposableElements: [UIView] {
        return coordinator.disposableElements.compactMap {
            let contentView = $0.view
            if let cell = coordinator.cells[contentView] {
                return cell
            }
            return contentView.subviews.first
        }
    }
    
    // MARK: - Private
    // 执行删除逻辑
    private func applyDeletion(completion: (() -> Void)? = nil) {
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
                    addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .top, constant: remainSpacing)
                } else if nextView == scrollView {
                    addConstraint(for: scrollView, item1: nextView, attr1: .bottom, item2: previousView, attr2: .bottom, constant: remainSpacing)
                } else {
                    addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .bottom, constant: remainSpacing)
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
                deletingViews.forEach { deleteView in
                    deleteView.removeFromSuperview()
                    self.coordinator.cells.removeValue(forKey: deleteView)
                }
                self.coordinator.elements.removeAll { $0.deleting }
                completion?()
            }
        }
    }
    
    //刷新
    private func reloadDisposableIfNeed() {
        triggerDisposable()
    }
}
