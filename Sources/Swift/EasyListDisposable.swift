//
//  EasyListDisposable.swift
//  EasyListViewExample
//
//  Created by carefree on 2022/10/8.
//  Copyright © 2022 carefree. All rights reserved.
//

import UIKit
import EasyCompatible

public extension EasyExtension where Base: UIScrollView {
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
}
