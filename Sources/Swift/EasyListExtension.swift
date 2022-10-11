//
//  EasyListExtension.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/8.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit
import EasyCompatible

private var EasyListCoordinatorKey = "EasyListCoordinatorKey"
//添加easy扩展
extension UIScrollView: EasyCompatible { }

public extension EasyExtension where Base: UIScrollView {
    
    internal enum SearchCondition {
        case first(UIView, NSLayoutConstraint.Attribute)
        case second(UIView, NSLayoutConstraint.Attribute)
        case both(UIView?, NSLayoutConstraint.Attribute,
                  UIView?, NSLayoutConstraint.Attribute)
    }
    
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
    
    // MARK: - Internal
    //插入动画
    internal func animateInsertion(completion: (() -> Void)? = nil, duration: TimeInterval) {
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
    internal func animateDeletion(completion: (() -> Void)? = nil, duration: TimeInterval) {
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
    internal func reloadDisposableIfNeed() {
        triggerDisposable()
    }
    
    //查找符合条件的约束
    internal func searchConstraintsIn(_ view: UIView, with conditions: [SearchCondition]) -> [NSLayoutConstraint] {
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
    internal func resetConstraintsForDeleting() {
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
    
    internal func lastStepForDeleting() {
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
    
    internal func lastStepForInserting() {
        coordinator.elements = coordinator.elements.map {
            var tmp = $0
            tmp.inserting = false
            return tmp
        }
    }
}
