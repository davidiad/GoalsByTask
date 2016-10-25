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
        // credit to globalnerdy.com/2015/01/03/how-to-program-an-ios-text-field-that-takes-only-numeric-input-with-a-maximum-length
        // for tutorial how to limit allowed text
        let textToCheck = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if string.characters.count > 0 {
            let entryNotTooLong = textToCheck.characters.count < 50
            result = entryNotTooLong
        }
        return result
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.Bezel
        textField.clearButtonMode = .Always
        textField.textAlignment = NSTextAlignment.Center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 18
        textField.autocorrectionType = .No
        
        // While editing, set a background color for the text, so the user has a cue that they are editing text
        let bgcolor = UIColor(hue: 0.72, saturation: 0.2, brightness: 0.9, alpha: 0.7)
        textField.backgroundColor = bgcolor

    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.None
        // Get rid of the bg color when done editing
        textField.backgroundColor = UIColor.clearColor()
        textField.clearButtonMode = .Never
        
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

