import UIKit
import Foundation

class AttributedStringBuilder {
    let string: NSString
    private let fullRange: NSRange
    private var addAttributes: (NSMutableAttributedString) -> Void = { _ in }

    init(string: String) {
        self.string = (string as NSString)
        self.fullRange = NSRange(location: 0, length: self.string.length)
    }
    
    func make() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string as String)
        addAttributes(attributedString)
        return NSAttributedString(attributedString: attributedString)
    }

    func font(_ font: UIFont) -> AttributedStringBuilder {
        return appendAttribute(.font, value: font)
    }
    
    func font(_ font: UIFont, substring: String) -> AttributedStringBuilder {
        return appendAttribute(.font, value: font, toSubstring: substring)
    }
    
    func foregroundColor(_ color: UIColor) -> AttributedStringBuilder {
        return appendAttribute(.foregroundColor, value: color)
    }
    
    func foregroundColor(_ color: UIColor, substring: String) -> AttributedStringBuilder {
        return appendAttribute(.foregroundColor, value: color, toSubstring: substring)
    }
    
    func paragraphStyle(_ paragraphStyle: NSParagraphStyle) -> AttributedStringBuilder {
        return appendAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    func paragraphStyle(_ paragraphStyle: NSParagraphStyle, substring: String) -> AttributedStringBuilder {
        return appendAttribute(.paragraphStyle, value: paragraphStyle, toSubstring: substring)
    }
    
    private func appendAttribute(_ attribute: NSAttributedString.Key, value: Any) -> AttributedStringBuilder {
        addAttributes = { [fullRange, addAttributes] in
            addAttributes($0)
            $0.addAttribute(attribute, value: value, range: fullRange)
        }
        return self
    }
    
    private func appendAttribute(_ attribute: NSAttributedString.Key, value: Any, toSubstring substring: String) -> AttributedStringBuilder {
        let range = string.range(of: substring)
        
        if range.location != NSNotFound {
            addAttributes = { [addAttributes] in
                addAttributes($0)
                $0.addAttribute(attribute, value: value, range: range)
            }
        }
        
        return self
    }
}


let source = "Hello😀, 😄world!"
let boldPart = "Hello"
let redPart = "world"

let attributedResult = AttributedStringBuilder(string: source)
                        .foregroundColor(.yellow)
                        .font(.boldSystemFont(ofSize: 20), substring: boldPart)
                        .font(.boldSystemFont(ofSize: 20), substring: redPart)
                        .foregroundColor(.red, substring: redPart)
                        .make()

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
label.attributedText = attributedResult
