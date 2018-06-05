//
//  DroppableView.swift
//  Blotchy
//
//  Created by Joshua May on 5/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

@objc protocol DroppableViewDelegate {
    func draggingEntered(with string: String)
    func draggingEnded(with string: String?)
    func draggingExited(with string: String?)
}

class DroppableView: NSView {
    weak var delegate: DroppableViewDelegate?

    func string(from draggingInfo: NSDraggingInfo) -> String? {
        let pboard = draggingInfo.draggingPasteboard

        guard
            let item = pboard.pasteboardItems?.first,
            let string = item.string(forType: .string)
            else {
                return nil
        }

        return string
    }

//    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
//        print("prepareForDragOperation: \(sender)")
//        return true
//    }
//
//    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
//        print("performDragOperation: \(sender)")
//        return true
//    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let string = string(from: sender) else {
            return NSDragOperation()
        }

        delegate?.draggingEntered(with: string)

        return .copy
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        guard let string = string(from: sender) else {
            return
        }

        delegate?.draggingEnded(with: string)
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        let string: String? = {
            guard let draggingInfo = sender else {
                return nil
            }

            return self.string(from: draggingInfo)
        }()

        delegate?.draggingExited(with: string)
    }
}
