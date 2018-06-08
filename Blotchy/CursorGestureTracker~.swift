//
//  CursorGestureTracker.swift
//  Blotchy
//
//  Created by Joshua May on 6/6/18.
//  Copyright © 2018 Joshua May. All rights reserved.
//

import Cocoa

protocol CursorGestureTrackerDelegate: NSObjectProtocol {
    func didFlingLeft()
    func didFlingRight()
}

enum Direction {
    case left
    case right
}

class CursorGestureTracker {
    weak var delegate: CursorGestureTrackerDelegate?

    // we need to travel at least `MinimumDistance` points within `MaximumTime` per direction
    let MinimumDistance: CGFloat = 250 // ¯\_(ツ)_/¯ magic value, from some trial and error on what feels right
    let MaximumTime: TimeInterval = 0.3 // seconds

    var monitorGlobal: Any?
    var monitorLocal: Any?

    var startingX: CGFloat?
    var startingTimestamp: TimeInterval = 0
//    var previousX: CGFloat?
    var direction: Direction?

    func start() {
        if monitorGlobal == nil {
            monitorGlobal = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
                self?.handleMouseMove(event: event)
            }
        }

        if monitorLocal == nil {
            monitorLocal = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
                self?.handleMouseMove(event: event)
                return event
            }
        }
    }

    func stop() {
        if let monitorGlobal = monitorGlobal {
            NSEvent.removeMonitor(monitorGlobal)
        }

        if let monitorLocal = monitorLocal {
            NSEvent.removeMonitor(monitorLocal)
        }

        startingX = nil
        direction = nil
    }

    // MARK: Events
    func handleMouseMove(event: NSEvent) {
        guard event.type == .mouseMoved else {
            print("event is not .mouseMoved: \(event)")
            return
        }

//        print(NSEvent.mouseLocation.x, event.deltaX)

        // lots to probably check here, that I'll naively ignore for now
        // I assume this breaks a lot for multi-screen setups?

        // TODO: avoid top/bottom 10% (?) of screen because of hot corners

        // initialise to sensible starting values
        guard
            let startingX = startingX
            else {
                self.startingX = NSEvent.mouseLocation.x
//                self.previousX = NSEvent.mouseLocation.x
                return
        }

        let currentX = NSEvent.mouseLocation.x
        let deltaX = event.deltaX

        let currentDirectionMaybe: Direction? = {
            if deltaX < -0.1 {
                return .left
            }

            if deltaX > 0.1 {
                return .right
            }

            // we haven't moved horizontally (at least, not significantly)
            return nil
        }()


        if direction != currentDirectionMaybe ||
            fabs(deltaX) < 0.1 {
            // reset, because we changed direction or stopped
//            print("changing direction (\(String(describing: currentDirectionMaybe)), or idle (\(fabs(deltaX) < 0.1))!")
            self.direction = currentDirectionMaybe
//            self.previousX = currentX
            self.startingX = currentX
            self.startingTimestamp = Date().timeIntervalSince1970
        }

        // if the mouse event if just vertical, then we don't care here, so bail
        guard let _ = currentDirectionMaybe else {
            return
        }

        // try to find the screen the cursor is on:
        let screenMaybe: NSScreen? = {
            for screen in NSScreen.screens {
                if NSMouseInRect(NSEvent.mouseLocation, screen.frame, false) {
                    return screen
                }
            }

            return nil
        }()

        guard let screen = screenMaybe else {
            print("warning: can't find screen for cursor, probably bad")
            return
        }

        let width = screen.frame.width
        let fraction: CGFloat = 0.5/100 // 0.5% of screen, to account for rounding
        let leftXThreshold = width * fraction
        let rightXThreshold = width - (width * fraction)

        let thresholdHit: Direction? = {
            if currentX < leftXThreshold {
                return .left
            } else if (currentX > rightXThreshold) {
                return .right
            }

            return nil
        }()

        let now = Date().timeIntervalSince1970
        let duration = now - startingTimestamp
        let withinTime = duration < MaximumTime

        let distance = fabs(currentX - startingX)
        let travelledFarEnough = distance > MinimumDistance

        if let thresholdHit = thresholdHit {
//            print("I think we hit the \(thresholdHit == .left ? "left" : "right") edge, cool")
//            print("it took \(duration)")
//            print("and travelled \(distance)")

            if withinTime,
                travelledFarEnough {
                switch thresholdHit {
                case .left:
                    self.delegate?.didFlingLeft()
                case .right:
                    self.delegate?.didFlingRight()
                }
            } else {
//                print("too slow? too long? sorry mate, try again later")
            }

            // we don't want to keep triggering within here, so, this should prevent anything firing:
            self.startingX = currentX
            self.startingTimestamp = 0
        }
    }
}
