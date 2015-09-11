//
//  ArrayExtensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension CollectionType {
    func mapFilter<T>(@noescape transform: (Self.Generator.Element) -> T?) -> [T] {
        return map{ transform($0) }.filter{ $0 != nil }.map{ $0! }
    }
}
