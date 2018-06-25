//
//  ClosedRange+Additions.swift
//  Blotchy
//
//  Created by Joshua May on 25/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Foundation

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}
