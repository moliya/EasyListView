//
//  EasyListDelete.swift
//  EasyListViewExample
//
//  Created by carefree on 2022/10/7.
//  Copyright © 2022 carefree. All rights reserved.
//

import UIKit
import EasyCompatible

public extension EasyExtension where Base: UIScrollView {
    /**
     删除一个视图元素
     
     * parameter view: 要删除的视图，可以是UIView，也可以是视图的唯一标识
     * parameter completion: 删除完成后的回调
     */
    func deleteView(_ view: Any, completion: (() -> Void)? = nil) {
        let elements = coordinator.elements
        
        var targetView: UIView?
        if let string = view as? String {
            targetView = elements.first { $0.identifier == string }?.view
        }
        if let cell = view as? UITableViewCell {
            targetView = coordinator.cells.first { $0.value == cell }?.key
        } else if let view = view as? UIView {
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
}
