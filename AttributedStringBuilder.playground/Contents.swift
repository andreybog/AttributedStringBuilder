import UIKit
import Foundation

class AttributedStringBuilder {
    enum Attribute {
        case font(UIFont)
        case foregroundColor(UIColor)
        case paragraphStyle(NSParagraphStyle)
        
        var keyValue: (NSAttributedString.Key, Any) {
            switch self {
            case .font(let font):
                return (.font, font)
            case .foregroundColor(let color):
                return (.foregroundColor, color)
            case .paragraphStyle(let style):
                return (.paragraphStyle, style)
            }
        }
    }
    
    private let string: NSString
    private let range: NSRange
    private var commands: [(NSMutableAttributedString) -> Void] = []
    private let ancestorString: (() -> NSAttributedString)?
    
    convenience init(string: String, attributes: [Attribute] = []) {
        self.init(string: string, attributes: attributes, ancestorString: nil)
    }
    
    convenience init(string: String, attributes: Attribute...) {
        self.init(string: string, attributes: attributes)
    }
    
    private init(string: NSString, range: NSRange, commands: [(NSMutableAttributedString) -> Void], ancestorString: (() -> NSAttributedString)?) {
        self.string = string
        self.range = range
        self.commands = commands
        self.ancestorString = ancestorString
    }
    
    private init(string: String, attributes: [Attribute], ancestorString: (() -> NSAttributedString)?) {
        self.string = string as NSString
        self.range = NSRange(location: 0, length: self.string.length)
        self.ancestorString = ancestorString
        _ = addAttributes(attributes)
    }
    
    func make() -> NSAttributedString {
        var result = NSMutableAttributedString(string: string as String)
        commands.forEach { $0(result) }
        
        if let ancestorString = (ancestorString?()).map(NSMutableAttributedString.init) {
            ancestorString.append(result)
            result = ancestorString
        }
        
        return NSAttributedString(attributedString: result)
    }
    
    func addAttributes(_ attributes: Attribute...) -> AttributedStringBuilder {
        return self.addAttributes(attributes)
    }
    
    func addAttributes(_ attributes: [Attribute]) -> AttributedStringBuilder {
        return addAttributes(attributes, toRange: range)
    }
    
    func modifySubstring(_ substring: String, attributes: Attribute...) -> AttributedStringBuilder {
        return self.modifySubstring(substring, attributes: attributes)
    }
    
    func modifySubstring(_ substring: String, attributes: [Attribute]) -> AttributedStringBuilder {
        let substringRange = string.range(of: substring)
        
        if substringRange.location != NSNotFound {
            return addAttributes(attributes, toRange: substringRange)
        } else {
            return self
        }
    }
    
    func append(string: String, attributes: Attribute...) -> AttributedStringBuilder {
        return self.append(string: string, attributes: attributes)
    }
    
    func append(string: String, attributes: [Attribute]) -> AttributedStringBuilder {
        let copy = self.copy()
        return AttributedStringBuilder(string: string, attributes: attributes, ancestorString: { copy.make() })
    }
    
    private func addAttributes(_ attributes: [Attribute], toRange range: NSRange) -> AttributedStringBuilder {
        if !attributes.isEmpty {
            let command = { (attributedString: NSMutableAttributedString) in
                let attributes: [NSAttributedString.Key: Any] = attributes.reduce(into: [:]) { $0[$1.keyValue.0] = $1.keyValue.1 }
                attributedString.addAttributes(attributes, range: range)
            }
            
            commands.append(command)
        }
        
        return self
    }
    
    private func copy() -> AttributedStringBuilder {
        return AttributedStringBuilder(string: string, range: range, commands: commands, ancestorString: ancestorString)
    }
}


let source = "Hello😀, 😄world!"
let boldPart = "Hello"
let redPart = "world"

let attributedResult = AttributedStringBuilder(string: source, attributes: .foregroundColor(.yellow))
                        .modifySubstring(boldPart, attributes: .font(.boldSystemFont(ofSize: 20)))
                        .modifySubstring(redPart, attributes: .font(.boldSystemFont(ofSize: 20)), .foregroundColor(.red))
                        .make()

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
label.attributedText = attributedResult
