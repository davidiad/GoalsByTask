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
    
    //let defaultText = "MEME TEXT GOES HERE"
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        // credit to globalnerdy.com/2015/01/03/how-to-program-an-ios-text-field-that-takes-only-numeric-input-with-a-maximum-length
        // for tutorial how to limit allowed text
        let textToCheck = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if string.characters.count > 0 {
            let entryNotTooLong = textToCheck.characters.count < 50
            result = entryNotTooLong
        }
        //textField.text = textField.text!.uppercaseString
        return result
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.Bezel
        textField.clearButtonMode = .Always
        textField.textAlignment = NSTextAlignment.Center
        //textField.placeholder = defaultText
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 18
        //textField.autocapitalizationType = .AllCharacters
        textField.autocorrectionType = .No
        
        // While editing, set a background color for the meme text, so the user has a cue that they are editing text
        let bgcolor = UIColor(hue: 0.62, saturation: 0.2, brightness: 0.9, alpha: 0.7)
        textField.backgroundColor = bgcolor
        //textField.layer.cornerRadius = 8.0;
        // Only remove default text, not user entered text
//        if textField.text == defaultText {
//            textField.text = ""
//        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.None
        // Get rid of the bg color when done editing
        textField.backgroundColor = UIColor.clearColor()
        textField.clearButtonMode = .Never
        //textField.text = textField.text!.uppercaseString
        
        // notification to save the context
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

