//
//  GoalTextFieldDelegate.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import UIKit


class GoalTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        // credit for tutorial how to limit allowed text to:
        // globalnerdy.com/2015/01/03/how-to-program-an-ios-text-field-that-takes-only-numeric-input-with-a-maximum-length
        
        let textToCheck = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if string.characters.count > 0 {
            let entryNotTooLong = textToCheck.characters.count < 70
            result = entryNotTooLong
        }
        return result
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.Bezel
        textField.clearButtonMode = .WhileEditing
        textField.textAlignment = NSTextAlignment.Center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 18
        textField.autocorrectionType = .No
        
        // While editing, set a background color for the text, so the user has a cue that they are editing text
        let bgcolor = UIColor(hue: 0.1, saturation: 0.09, brightness: 1.0, alpha: 1.0)
        textField.backgroundColor = bgcolor
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.None
        // Get rid of the bg color when done editing
        textField.backgroundColor = UIColor.whiteColor()
        textField.clearButtonMode = .WhileEditing
        
        // notification to save the name change into the managed object context
        NSNotificationCenter.defaultCenter().postNotificationName(saveNameChangeNotificationKey, object: self)
        
    }
    
    // When the clear button is tapped...
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

