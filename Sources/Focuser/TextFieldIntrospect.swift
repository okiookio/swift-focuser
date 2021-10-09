//
//  File.swift
//  
//
//  Created by Augustinas Malinauskas on 01/09/2021.
//

import SwiftUI
import Introspect

class TextFieldObserver: NSObject, UITextFieldDelegate {
    var onReturnTap: () -> () = {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnTap()
        return false
    }
}

public struct FocusModifier<Value: FocusStateCompliant & Hashable>: ViewModifier {
    @Binding var focusedField: Value?
    var equals: Value
    @State var observer = TextFieldObserver()
    
    public func body(content: Content) -> some View {
        let configToolBar: (UITextField) -> Void = { textField in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
            doneToolbar.items = [flexSpace, done]
            doneToolbar.sizeToFit()
            textField.inputAccessoryView = doneToolbar
            done.target = textField
            done.action = #selector( textField.resignFirstResponder )
        }
        
        content
            .introspectTextField { tf in
                configToolBar(tf)
                tf.delegate = observer
                
                /// when user taps return we navigate to next responder
                observer.onReturnTap = {
                    focusedField = focusedField?.next ?? Value.last
                    
                    if equals.hashValue == Value.last.hashValue {
                        tf.resignFirstResponder()
                    }
                }

                /// to show kayboard with `next` or `return`
                if equals.hashValue == Value.last.hashValue {
                    tf.returnKeyType = .done
                } else {
                    tf.returnKeyType = .next
                }
                
                if focusedField == equals {
                    tf.becomeFirstResponder()
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
              focusedField = equals
            })
    }
}
