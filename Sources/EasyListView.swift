//
//  EasyListView.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/6/11.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

@objcMembers
open class EasyListView: UIScrollView {
    
    private var observation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    deinit {
        observation?.invalidate()
        observation = nil
    }
    
    // MARK: - Private
    private func commonInit() {
        observation = self.observe(\.contentOffset, options: [.initial, .new]) {[weak self] _, _ in
            self?.easy.triggerDisposable()
        }
    }
}

internal class EasyListContentView: UIView {
    
    var disposableMaker: (() -> UIView)? = nil
    
}
