//
//  EasyListObjC.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/18.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

@objc open class EasyListObjCAttributes: NSObject {
    fileprivate var attributes: EasyListAttributes
    
    init(_ attributes: EasyListAttributes) {
        self.attributes = attributes
        super.init()
    }
}

@objc public extension EasyListObjCAttributes {
    /**
     设置唯一标识
     
     * parameter identifier: 标识字符串
     
     * returns: 自定义配置项
     */
    var identifier: (String) -> EasyListObjCAttributes {
        return { identifier in
            self.attributes.identifier(identifier)
            return self
        }
    }
    
    /**
     设置内间距
     
     * parameter insets: 内间距
     
     * returns: 自定义配置项
     */
    var insets: (UIEdgeInsets) -> EasyListObjCAttributes {
        return { insets in
            self.attributes.insets(insets)
            return self
        }
    }
    
    /**
     设置与上一元素的间距
     
     * parameter spacing: 间距
     
     * returns: 自定义配置项
     */
    var spacing: (CGFloat) -> EasyListObjCAttributes {
        return { spacing in
            self.attributes.spacing(spacing)
            return self
        }
    }
    
    /**
     设置超出部分是否裁剪
     
     * parameter clipsToBounds: 是否裁剪
     
     * returns: 自定义配置项
     */
    var clipsToBounds: (Bool) -> EasyListObjCAttributes {
        return { clipsToBounds in
            self.attributes.clipsToBounds(clipsToBounds)
            return self
        }
    }
}

@available(*, unavailable)
@objc public extension UIScrollView {
    // MARK: - Coordinator
    var easy_coordinator: EasyListCoordinator {
        get {
            return easy.coordinator
        }
        set {
            easy.coordinator = newValue
        }
    }
    
    // MARK: - Append
    /**
     添加一个视图元素
     
     * parameter view: 视图
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_appendView(_ view: UIView) -> EasyListObjCAttributes {
        let attributes = easy.appendView(view)
        return EasyListObjCAttributes(attributes)
    }
    
    /**
     添加一个视图元素
     
     * parameter block: 视图block
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_appendViewBy(_ block: () -> UIView) -> EasyListObjCAttributes {
        let attributes = easy.appendView(block)
        return EasyListObjCAttributes(attributes)
    }
    
    // MARK: - Insert
    /**
     在目标之后插入一个视图元素
     
     * parameter view: 视图
     * parameter element: 前一个视图元素，可以是UIView，也可以是视图唯一标识
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_insertView(_ view: UIView, after element: Any) -> EasyListObjCAttributes {
        let attributes = easy.insertView(view, after: element)
        return EasyListObjCAttributes(attributes)
    }
    
    /**
     在目标之后插入一个视图元素
     
     * parameter block: 视图block
     * parameter element: 前一个视图元素，可以是UIView，也可以是视图唯一标识
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_insertViewBy(_ block: () -> UIView, after element: Any) -> EasyListObjCAttributes {
        let attributes = easy.insertView(block, after: element)
        return EasyListObjCAttributes(attributes)
    }
    
    /**
     在目标之前插入一个视图元素
     
     * parameter view: 视图
     * parameter element: 后一个视图元素，可以是UIView，也可以是视图唯一标识
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_insertView(_ view: UIView, before element: Any) -> EasyListObjCAttributes {
        let attributes = easy.insertView(view, before: element)
        return EasyListObjCAttributes(attributes)
    }
    
    /**
     在目标之前插入一个视图元素
     
     * parameter block: 视图block
     * parameter element: 后一个视图元素，可以是UIView，也可以是视图唯一标识
     
     * returns: 自定义配置项
     */
    @discardableResult
    func easy_insertViewBy(_ block: () -> UIView, before element: Any) -> EasyListObjCAttributes {
        let attributes = easy.insertView(block, before: element)
        return EasyListObjCAttributes(attributes)
    }
    
    // MARK: - Delete
    /**
     删除一个视图元素
     
     * parameter view: 要删除的视图，可以是UIView，也可以是视图的唯一标识
     */
    func easy_deleteView(_ view: Any) {
        easy.deleteView(view)
    }
    
    /**
     删除一个视图元素
     
     * parameter view: 要删除的视图，可以是UIView，也可以是视图的唯一标识
     * parameter completion: 删除完成后的回调
     */
    func easy_deleteView(_ view: Any, completion: (() -> Void)?) {
        easy.deleteView(view, completion: completion)
    }
    
    /**
     删除所有视图元素
     
     */
    func easy_deleteAll() {
        easy.deleteAll()
    }
    
    // MARK: - BatchUpdate
    /**
     开始批量更新操作
     
     * Note: 需和endUpdates成对使用。
     */
    func easy_beginUpdates() {
        easy.beginUpdates()
    }
    
    /**
     开始批量更新操作
     
     * parameter option: 更新方式
     * Note: 需和endUpdates成对使用。
     */
    func easy_beginUpdates(option: EasyListUpdateOption) {
        easy.beginUpdates(option: option)
    }
    
    /**
     完成批量更新操作
     
     */
    func easy_endUpdates() {
        easy.endUpdates()
    }
    
    /**
     完成批量更新操作
     
     * parameter completion: 更新完成后的回调
     */
    func easy_endUpdates(completion: (() -> Void)?) {
        easy.endUpdates(completion)
    }
    
    // MARK: - Disposable
    /**
     生成自释放元素
     
     * parameter maker: 闭包
     
     * returns: 生成的视图
     */
    func easy_disposableView(maker: @escaping () -> UIView) -> UIView {
        return easy.disposableView(with: maker)
    }
    
    /**
     刷新数据
     
     */
    func easy_reloadDisposableData() {
        easy.reloadDisposableData()
    }
    
    /**
     触发自释放机制
     
     */
    func easy_triggerDisposable() {
        easy.triggerDisposable()
    }
    
    // MARK: - Getter
    /**
     获取视图元素
     
     * parameter identifier: 视图唯一标识
     
     * returns: 找到的视图
     */
    func easy_getElement(identifier: String) -> AnyObject? {
        return easy.getElement(identifier: identifier)
    }
    
    /**
     获取指定下标的自释放元素
     
     * parameter index: 下标
     
     * returns: 找到的视图
     */
    func easy_getDisposableElementAtIndex(_ index: Int) -> AnyObject? {
        return easy.getDisposableElement(at: index)
    }
    
    /**
     获取所有可视的自释放元素
     
     * returns: 找到的视图集合
     */
    var easy_visibleDisposableElements: [AnyObject] {
        return easy.visibleDisposableElements
    }
}
