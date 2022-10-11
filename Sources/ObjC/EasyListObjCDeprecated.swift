//
//  EasyListObjCDeprecated.swift
//  EasyListViewExample
//
//  Created by carefree on 2022/10/8.
//  Copyright © 2022 carefree. All rights reserved.
//

import UIKit

@available(*, unavailable)
@objc public extension UIScrollView {
    // MARK: - Append
    @available(*, deprecated, message: "Please use easy_appendView: instead.")
    func easy_appendView(_ view: UIView, spacing: CGFloat) {
        easy.append(view, spacing: spacing)
    }
    
    @available(*, deprecated, message: "Please use easy_appendViewBy: instead.")
    func easy_appendViewBy(_ block: () -> UIView, spacing: CGFloat) {
        easy.append(block(), spacing: spacing)
    }
    
    @available(*, deprecated, message: "Please use easy_appendView: instead.")
    func easy_appendView(_ view: UIView, forIdentifier identifier: String, spacing: CGFloat) {
        easy.append(view, for: identifier, spacing: spacing)
    }
    
    @available(*, deprecated, message: "Please use easy_appendViewBy: instead.")
    func easy_appendViewBy(_ block: () -> UIView, forIdentifier identifier: String, spacing: CGFloat) {
        easy.append(block(), for: identifier, spacing: spacing)
    }
    
    @available(*, deprecated, message: "Please use easy_appendView: instead.")
    func easy_appendView(_ view: UIView, forIdentifier identifier: String, withInsets insets: UIEdgeInsets) {
        easy.append(view, with: insets, for: identifier)
    }
    
    @available(*, deprecated, message: "Please use easy_appendViewBy: instead.")
    func easy_appendViewBy(_ block: () -> UIView, forIdentifier identifier: String, withInsets insets: UIEdgeInsets) {
        easy.append(block(), with: insets, for: identifier)
    }
    
    // MARK: - Insert
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(view, after: element, with: insets)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(block(), after: element, with: insets)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(view, after: element, with: insets, for: identifier)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(block(), after: element, with: insets, for: identifier)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(view, after: element, with: insets, for: identifier, completion: completion)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:after: instead.")
    func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(block(), after: element, with: insets, for: identifier, completion: completion)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(view, before: element, with: insets)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(block(), before: element, with: insets)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(view, before: element, with: insets, for: identifier)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(block(), before: element, with: insets, for: identifier)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(view, before: element, with: insets, for: identifier, completion: completion)
    }
    
    @available(*, deprecated, message: "Please use easy_insertView:before: instead.")
    func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(block(), before: element, with: insets, for: identifier, completion: completion)
    }
    
    // MARK: - Delete
    @available(*, deprecated, message: "Please use easy_deleteView: instead.")
    func easy_deleteElement(_ element: Any) {
        easy.delete(element)
    }
    
    @available(*, deprecated, message: "Please use easy_deleteView:completion: instead.")
    func easy_deleteElement(_ element: Any, completion: (() -> Void)?) {
        easy.delete(element, completion: completion)
    }
}
