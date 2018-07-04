import Cocoa

@objc(Context)
open class Context: _Context {
    @objc dynamic var color: NSColor {
        get {
            guard
                let color = colorTransformable as? NSColor
                else {
                    fatalError("colorTransformable is not an NSColor")
            }

            return color
        }

        set {
            colorTransformable = newValue
        }
    }

    @objc dynamic var terms: NSMutableArray {
        get {
            guard
                let terms = termsTransformable as? [String]
                else {
                    fatalError("termsTransformable is not an [String]")
            }

            return NSMutableArray(array: terms)
        }
        set {
            termsTransformable = newValue
        }
    }
}
