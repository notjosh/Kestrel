//
//  ProgressBar.swift
//  Blotchy
//
//  Created by Joshua May on 25/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa
import QuartzCore

let ProgressBarDefaultAnimationTime: Double = 0.2
let ProgressBarMaximum: Double = 100

class ProgressBar: NSView {
    fileprivate let progressLayer = CALayer()

    fileprivate var progressValue: Double = 0

    var progress: Double {
        set {
            setProgress(newValue, animated: false)
        }
        get {
            return progressValue
        }
    }

    var tintColor: NSColor = {
        if #available(OSX 10.14, *) {
            return .controlAccentColor
        }

        // XXX: is this right for macOS < 10.14?
        return NSColor(for: NSColor.currentControlTint)
        }() {
        didSet {
            progressLayer.backgroundColor = tintColor.cgColor
        }
    }

    var backgroundColor: NSColor = .clear {
        didSet {
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        wantsLayer = true

        progressLayer.backgroundColor = tintColor.cgColor

        if let layer = layer {
            layer.backgroundColor = backgroundColor.cgColor
            layer.addSublayer(progressLayer)
        }

        update(false)
    }

    func setProgress(_ progress: Double, animated: Bool) {
        progressValue = progress.clamped(to: 0.0...ProgressBarMaximum)

        update(animated)
    }

    func update(_ animated: Bool) {
        let percent = progressValue / ProgressBarMaximum
        let targetWidth = bounds.width * CGFloat(percent)
        let targetFrame = CGRect(origin: bounds.origin, size: CGSize(width: targetWidth, height: bounds.height))

        if animated {
            let animation = CABasicAnimation(keyPath: "frame")
            animation.fromValue = progressLayer.frame
            animation.toValue = targetFrame
            animation.duration = ProgressBarDefaultAnimationTime
            animation.timingFunction = CAMediaTimingFunction(name: .linear)

            progressLayer.frame = targetFrame
            progressLayer.add(animation, forKey: "frame")
        } else {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            progressLayer.frame = targetFrame
            CATransaction.commit()
        }
    }
}
