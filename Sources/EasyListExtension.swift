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
    
    internal enum SearchCondition {
        case first(UIView, NSLayoutConstraint.Attribute)
        case second(UIView, NSLayoutConstraint.Attribute)
        case both(UIView?, NSLayoutConstraint.Attribute,
                  UIView?, NSLayoutConstraint.Attribute)
    }
    
    typealias ViewOrClosure = Any
    internal typealias Element = EasyListCoordinator.Element
    
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
        
        insert(view, previousView: previousView, nextView: nextView, index: index, with: insets, for: identifier, completion: completion)
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
        
        insert(view, previousView: previousView, nextView: nextView, index: index, with: insets, for: identifier, completion: completion)
    }
    
    /**
     插入一个视图元素
     
     * parameter view: 视图或闭包
     * parameter previousView: 前一个视图元素
     * parameter nextView: 后一个视图元素
     * parameter index: 插入的下标
     * parameter insets: 视图自定义的间距
     * parameter identifier: 视图唯一标识
     * parameter completion: 插入完成回调
     */
    internal func insert(_ view: ViewOrClosure, previousView: UIView?, nextView: UIView?, index: Int, with insets: UIEdgeInsets, for identifier: String, completion: (() -> Void)?) {
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
    
    // MARK: - Delete
    /**
    删除一个视图元素
    
    * parameter element: 要删除的视图，可以是UIView，也可以是视图的唯一标识
    * parameter completion: 删除完成后的回调
    */
    func delete(_ element: Any, completion: (() -> Void)? = nil) {
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
        
        coordinator.elements = coordinator.elements.map {
            var tmp = $0
            if targetView == tmp.view && !tmp.deleting {
                tmp.deleting = true
            }
            return tmp
        }
        
        if coordinator.onBatchUpdate {
            completion?()
            return
        }
        
        animateDeletion(completion: {
            self.reloadDisposableIfNeed()
            completion?()
        }, duration: coordinator.animationDuration)
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
    
    * parameter option: 更新方式
    * Note: 需和endUpdates成对使用。
    */
    func beginUpdates(option: EasyListUpdateOption = .animatedLayout) {
        coordinator.onBatchUpdate = true
        coordinator.batchUpdateOption = option
    }
    
    /**
    完成批量更新操作
     
    * parameter completion: 更新完成后的回调
    */
    func endUpdates(_ completion: (() -> Void)? = nil) {
        coordinator.onBatchUpdate = false
        
        let insertingCount = coordinator.elements.filter { $0.inserting }.count
        let deletingCount = coordinator.elements.filter { $0.deleting }.count
        
        //不执行layout
        if coordinator.batchUpdateOption == .noLayout {
            //清理标记
            if insertingCount > 0 {
                lastStepForInserting()
            }
            if deletingCount > 0 {
                lastStepForDeleting()
            }
            //完成回调
            completion?()
            return
        }
        
        //无动画的layout
        if coordinator.batchUpdateOption == .onlyLayout {
            //更新约束
            resetConstraintsForDeleting()
            base.layoutIfNeeded()
            self.reloadDisposableIfNeed()
            //清理标记
            if insertingCount > 0 {
                lastStepForInserting()
            }
            if deletingCount > 0 {
                lastStepForDeleting()
            }
            //完成回调
            completion?()
            return
        }
        
        //带动画的layout
        let duration = coordinator.animationDuration
        if insertingCount > 0 && deletingCount > 0 {
            //先执行插入动画
            self.animateInsertion(completion: {
                //再执行删除动画
                self.animateDeletion(completion: completion, duration: duration / 2)
            }, duration: duration / 2)
        } else if insertingCount > 0 {
            //执行插入动画
            self.animateInsertion(completion: completion, duration: duration)
        } else if deletingCount > 0 {
            //执行删除动画
            self.animateDeletion(completion: completion, duration: duration)
        } else {
            //兜底代码
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
                    addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading, constant: element.insets.left)
                    addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing, constant: -element.insets.right)
                    addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top, constant: element.insets.top)
                    addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom, constant: -element.insets.bottom)
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
    //插入动画
    private func animateInsertion(completion: (() -> Void)? = nil, duration: TimeInterval) {
        let scrollView = base
        let elements = coordinator.elements
        
        //替换bottom约束为高度约束
        let insertingViews = elements.filter { $0.inserting }.map { $0.view }
        var heightConstraints = [(constraint: NSLayoutConstraint, subview: UIView, offset: CGFloat)]()
        var bottomConstraints = [NSLayoutConstraint]()
        for view in insertingViews {
            var offset: CGFloat = 0
            searchConstraintsIn(view, with: [
                .first(view, .top),
                .second(view, .top),
                .first(view, .bottom),
                .second(view, .bottom)
            ]).forEach {
                if $0.firstAttribute == .top || $0.secondAttribute == .top {
                    offset += $0.constant
                } else {
                    bottomConstraints.append($0)
                    $0.isActive = false
                    offset -= $0.constant
                }
            }
            let constraint = addConstraint(for: view, item1: view, attr1: .height, item2: nil, attr2: .notAnAttribute)
            heightConstraints.append((constraint, view.subviews.first!, offset))
        }
        
        scrollView.layoutIfNeeded()
        //更新高度约束
        heightConstraints.forEach {
            $0.constraint.constant = $0.subview.frame.size.height + $0.offset
        }
        UIView.animate(withDuration: duration, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            self.reloadDisposableIfNeed()
            //删除height约束
            heightConstraints.forEach {
                $0.constraint.isActive = false
            }
            //恢复bottom约束
            bottomConstraints.forEach {
                $0.isActive = true
            }
            self.lastStepForInserting()
            completion?()
        }
    }
    
    // 删除动画
    private func animateDeletion(completion: (() -> Void)? = nil, duration: TimeInterval) {
        let scrollView = base
        let elements = coordinator.elements
        
        //替换bottom约束为高度约束
        let deletingViews = elements.filter { $0.deleting }.map { $0.view }
        if deletingViews.count == 0 {
            completion?()
            return
        }
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
        
        //更新布局
        UIView.animate(withDuration: duration * 3 / 4, animations: {
            scrollView.layoutIfNeeded()
        }) { _ in
            //更新约束
            self.resetConstraintsForDeleting()
            UIView.animate(withDuration: duration / 4, animations: {
                scrollView.layoutIfNeeded()
            }) { _ in
                //完成后移除相关元素
                self.lastStepForDeleting()
                completion?()
            }
        }
    }
    
    //刷新
    private func reloadDisposableIfNeed() {
        triggerDisposable()
    }
    
    //查找符合条件的约束
    private func searchConstraintsIn(_ view: UIView, with conditions: [SearchCondition]) -> [NSLayoutConstraint] {
        var results = [NSLayoutConstraint]()
        for constraint in view.constraints {
            for condition in conditions {
                switch condition {
                case .first(let firstItem, let firstAttribute):
                    //匹配first
                    guard let item = constraint.firstItem as? UIView else { break }
                    if item == firstItem && constraint.firstAttribute == firstAttribute {
                        results.append(constraint)
                    }
                case .second(let secondItem, let secondAttribute):
                    //匹配second
                    guard let item = constraint.secondItem as? UIView else { break }
                    if item == secondItem && constraint.secondAttribute == secondAttribute {
                        results.append(constraint)
                    }
                case .both(let firstItem, let firstAttribute, let secondItem, let secondAttribute):
                    //匹配全部
                    guard let first = constraint.firstItem as? UIView, let second = constraint.secondItem as? UIView else {
                        break
                    }
                    if first == firstItem &&
                        second == secondItem &&
                        constraint.firstAttribute == firstAttribute &&
                        constraint.secondAttribute == secondAttribute {
                        results.append(constraint)
                    }
                }
            }
        }
        return results
    }
    
    //针对删除的元素重新构建约束
    private func resetConstraintsForDeleting() {
        let scrollView = base
        
        var list = [(UIView, UIView)]()
        var previousView: UIView = scrollView
        var nextView: UIView?
        var flag = false
        for element in coordinator.elements {
            if element.deleting {
                flag = true
                continue
            }
            if flag {
                nextView = element.view
            } else {
                previousView = element.view
            }
            if let view = nextView {
                list.append((previousView, view))
                
                previousView = element.view
                nextView = nil
                flag = false
            }
        }
        if flag {
            list.append((previousView, scrollView))
        }
        for (previousView, nextView) in list {
            if previousView == nextView {
                continue
            }
            if previousView == scrollView {
                addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .top)
            } else if nextView == scrollView {
                addConstraint(for: scrollView, item1: nextView, attr1: .bottom, item2: previousView, attr2: .bottom)
            } else {
                addConstraint(for: scrollView, item1: nextView, attr1: .top, item2: previousView, attr2: .bottom)
            }
        }
    }
    
    private func lastStepForDeleting() {
        coordinator.elements.filter {
            return $0.deleting
        }.map {
            return $0.view
        }.forEach {
            $0.removeFromSuperview()
            self.coordinator.cells.removeValue(forKey: $0)
        }
        coordinator.elements.removeAll { $0.deleting }
    }
    
    private func lastStepForInserting() {
        coordinator.elements = coordinator.elements.map {
            var tmp = $0
            tmp.inserting = false
            return tmp
        }
    }
}
