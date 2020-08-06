//
//  EasyListReusable.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/6.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

open class EasyListReusable {
    
    struct Element {
        var view: UIView
        var maker: () -> UIView
    }
    
    weak private(set) var scrollView: UIScrollView?
    fileprivate var elements = [Element]()
    
    public init(with scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    public func updateContentOffset() {
        guard let scrollView = scrollView else { return }
        
        let offset = scrollView.contentOffset.y
        let range = scrollView.frame.height
        let minY = offset - range
        let maxY = offset + range + range
        elements.forEach { element in
            let contentView = element.view
            guard let frame = contentView.superview?.frame else { return }
            
            if frame.maxY >= minY && frame.minY <= maxY {
                //在可视范围内
                if contentView.subviews.count == 0 {
                    //恢复子视图
                    let view = element.maker()
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
                    contentView.subviews.forEach { $0.removeFromSuperview() }
                }
            }
        }
    }
}

public extension EasyListExtension where Base: UIScrollView {
    
    func reusableView(with maker: @escaping () -> UIView) -> UIView {
        let contentView = UIView()
        let view = maker()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        addConstraint(for: contentView, item1: view, attr1: .leading, item2: contentView, attr2: .leading)
        addConstraint(for: contentView, item1: view, attr1: .trailing, item2: contentView, attr2: .trailing)
        addConstraint(for: contentView, item1: view, attr1: .top, item2: contentView, attr2: .top)
        addConstraint(for: contentView, item1: view, attr1: .bottom, item2: contentView, attr2: .bottom)
        
        coordinator.reusable.elements.append(EasyListReusable.Element(view: contentView, maker: maker))
        
        return contentView
    }
    
}
