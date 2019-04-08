import UIKit

extension UITextField {
    var selectedRange : NSRange {
        get {
            let begin = self.beginningOfDocument;
            let start = self.selectedTextRange?.start;
            let end = self.selectedTextRange?.end;

            let loc = self.offset(from: begin, to: start!);
            let len = self.offset(from: start!, to: end!);

            return NSRange(location: loc, length: len);
        }

        set {
            let begin = self.beginningOfDocument;
            let startPos = self.position(from: begin, offset: newValue.location);
            let endPos = self.position(from: begin, offset: newValue.location + newValue.length);
            let selectionRange = self.textRange(from: startPos!, to: endPos!);
            self.selectedTextRange = selectionRange;
        }
    }
}
