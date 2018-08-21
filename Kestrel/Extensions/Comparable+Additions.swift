//
//  Comparable+Additions.swift
//  Kestrel
//
//  Created by Joshua May on 25/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }
}
