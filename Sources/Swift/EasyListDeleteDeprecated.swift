//
//  EasyListDeleteDeprecated.swift
//  EasyListView
//
//  Created by carefree on 2022/10/10.
//

import UIKit
import EasyCompatible

public extension EasyExtension where Base: UIScrollView {
    /**
     删除一个视图元素
     
     * parameter element: 要删除的视图，可以是UIView，也可以是视图的唯一标识
     * parameter completion: 删除完成后的回调
     */
    @available(*, deprecated, renamed: "deleteView(_:completion:)", message: "Please use deleteView(_:completion:) instead.")
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
}
