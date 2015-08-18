//
//  ArrayExtensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation
/*
/// Return first element and all remaining items separately
func decompose<T>(arr: [T]) -> (head: T, tail: [T])? {
    return (arr.count > 0) ? (arr[0], Array(arr[1..<arr.count])) : nil
}

func between<T>(x: T, arr: [T]) -> [[T]] {
    if let (head, tail) = decompose(arr) {
        return [[x] + arr] + between(x, arr: tail).map { [head] + $0 }
    } else {
        return [[x]]
    }
}

/// Return all permutations of a given array [1,2] = [[1,2], [2,1]]
func permutations<T>(arr: [T]) -> [[T]] {
    if let (head, tail) = decompose(arr) {
        return permutations(tail) >>= { permTail in
            between(head, arr: permTail)
        }
    } else {
        return [[]]
    }
}
*/

extension CollectionType {
    func mapFilter<T>(@noescape transform: (Self.Generator.Element) -> T?) -> [T] {
        return map{ transform($0) }.filter{ $0 != nil }.map{ $0! }
    }
}
