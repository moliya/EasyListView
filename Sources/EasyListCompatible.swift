//
//  EasyListCompatible.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/6/11.
//  Copyright © 2020 carefree. All rights reserved.
//

import Foundation

// MARK: - 命名空间
public struct EasyListExtension<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol EasyListCompatible: AnyObject { }

public protocol EasyListCompatibleValue {}

extension EasyListCompatible {
    public var easy: EasyListExtension<Self> {
        get { return EasyListExtension(self) }
        set { }
    }
}

extension EasyListCompatibleValue {
    public var easy: EasyListExtension<Self> {
        get { return EasyListExtension(self) }
        set { }
    }
}
