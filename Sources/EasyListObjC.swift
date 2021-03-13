//
//  EasyListObjC.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/18.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    // MARK: - Coordinator
    @objc var easy_coordinator: EasyListCoordinator {
        get {
            return easy.coordinator
        }
        set {
            easy.coordinator = newValue
        }
    }
    
    // MARK: - Append
    @objc func easy_appendView(_ view: UIView) {
        easy.append(view)
    }
    
    @objc func easy_appendViewBy(_ block: () -> UIView) {
        easy.append(block())
    }
    
    @objc func easy_appendView(_ view: UIView, spacing: CGFloat) {
        easy.append(view, spacing: spacing)
    }
    
    @objc func easy_appendViewBy(_ block: () -> UIView, spacing: CGFloat) {
        easy.append(block(), spacing: spacing)
    }
    
    @objc func easy_appendView(_ view: UIView, forIdentifier identifier: String, spacing: CGFloat) {
        easy.append(view, for: identifier, spacing: spacing)
    }
    
    @objc func easy_appendViewBy(_ block: () -> UIView, forIdentifier identifier: String, spacing: CGFloat) {
        easy.append(block(), for: identifier, spacing: spacing)
    }
    
    @objc func easy_appendView(_ view: UIView, forIdentifier identifier: String, withInsets insets: UIEdgeInsets) {
        easy.append(view, with: insets, for: identifier)
    }
    
    @objc func easy_appendViewBy(_ block: () -> UIView, forIdentifier identifier: String, withInsets insets: UIEdgeInsets) {
        easy.append(block(), with: insets, for: identifier)
    }
    
    // MARK: - Insert
    @objc func easy_insertView(_ view: UIView, after element: Any) {
        easy.insert(view, after: element)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, after element: Any) {
        easy.insert(block(), after: element)
    }
    
    @objc func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(view, after: element, with: insets)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(block(), after: element, with: insets)
    }
    
    @objc func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(view, after: element, with: insets, for: identifier)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(block(), after: element, with: insets, for: identifier)
    }
    
    @objc func easy_insertView(_ view: UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(view, after: element, with: insets, for: identifier, completion: completion)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, after element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(block(), after: element, with: insets, for: identifier, completion: completion)
    }
    
    @objc func easy_insertView(_ view: UIView, before element: Any) {
        easy.insert(view, before: element)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, before element: Any) {
        easy.insert(block(), before: element)
    }
    
    @objc func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(view, before: element, with: insets)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets) {
        easy.insert(block(), before: element, with: insets)
    }
    
    @objc func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(view, before: element, with: insets, for: identifier)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String) {
        easy.insert(block(), before: element, with: insets, for: identifier)
    }
    
    @objc func easy_insertView(_ view: UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(view, before: element, with: insets, for: identifier, completion: completion)
    }
    
    @objc func easy_insertViewBy(_ block: () -> UIView, before element: Any, withInsets insets: UIEdgeInsets, forIdentifier identifier: String, completion: (() -> Void)?) {
        easy.insert(block(), before: element, with: insets, for: identifier, completion: completion)
    }
    
    // MARK: - Delete
    @objc func easy_deleteElement(_ element: Any) {
        easy.delete(element)
    }
    
    @objc func easy_deleteElement(_ element: Any, remainSpacing spacing: CGFloat) {
        easy.delete(element, remainSpacing: spacing)
    }
    
    @objc func easy_deleteElement(_ element: Any, remainSpacing spacing: CGFloat, completion: (() -> Void)?) {
        easy.delete(element, remainSpacing: spacing, completion: completion)
    }
    
    @objc func easy_deleteAll() {
        easy.deleteAll()
    }
    
    // MARK: - BatchUpdate
    @objc func easy_beginUpdates() {
        easy.beginUpdates()
    }
    
    @objc func easy_endUpdates() {
        easy.endUpdates()
    }
    
    @objc func easy_endUpdates(completion: (() -> Void)?) {
        easy.endUpdates(completion)
    }
    
    // MARK: - Disposable
    @objc func easy_disposableView(maker: @escaping () -> UIView) -> UIView {
        return easy.disposableView(with: maker)
    }
    
    @objc func easy_reloadDisposableData() {
        easy.reloadDisposableData()
    }
    
    @objc func easy_triggerDisposable() {
        easy.triggerDisposable()
    }
    
    // MARK: - Getter
    @objc func easy_getElement(identifier: String) -> UIView? {
        return easy.getElement(identifier: identifier)
    }
    
    @objc func easy_getDisposableElementAtIndex(_ index: Int) -> UIView? {
        return easy.getDisposableElement(at: index)
    }
    
    @objc var easy_visibleDisposableElements: [UIView] {
        return easy.visibleDisposableElements
    }
}
