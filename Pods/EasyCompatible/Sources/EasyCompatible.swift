//
//  EasyCompatible.swift
//  EasyCompatible
//
//  Created by carefree on 2022/3/25.
//  Copyright © 2019 Carefree. All rights reserved.
//

import Foundation

// MARK: - 命名空间
public struct EasyExtension<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol EasyCompatible: AnyObject { }

public protocol EasyCompatibleValue {}

extension EasyCompatible {
    public var easy: EasyExtension<Self> {
        get { return EasyExtension(self) }
        set { }
    }
}

extension EasyCompatibleValue {
    public var easy: EasyExtension<Self> {
        get { return EasyExtension(self) }
        set { }
    }
}
