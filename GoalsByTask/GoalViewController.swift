//
//  GoalViewController.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class GoalViewController: UIViewController {
    
    //MARK: Constants
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let goalTextFieldDelegate = GoalTextFieldDelegate()

    //MARK: Vars
    var goalOrder: Int?
    
    //MARK: Outlets
    @IBOutlet weak var goalNameTextField: UITextField!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var createGoalButton: UIButton!
    
    //MARK: Actions
    @IBAction func createGoal(sender: AnyObject) {
        
        view.endEditing(true) // dismiss the keyboard
        
        guard let newGoalName = goalNameTextField.text else {
            feedbackLabel.text = "Please give the goal a name before adding it"
            return
        }
        
        if newGoalName == "" {
            feedbackLabel.text = "Please name the goal before adding it"
        } else {
            
            // init a new managed object
            let newGoal = Goal(name: newGoalName, context: managedObjectContext)
            newGoal.order = goalOrder
            
            dispatch_async(dispatch_get_main_queue()) {
                self.appDelegate.saveContext()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    //MARK: - App lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        goalNameTextField.delegate = goalTextFieldDelegate
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(textFieldDidChange(_:)),
                                       name: UITextFieldTextDidChangeNotification,
                                       object: nil)
    }
    
    //MARK:- Textfield editing
    func textFieldDidChange(sender : AnyObject) {
        if let notification = sender as? NSNotification,
            textFieldChanged = notification.object as? UITextField
            where textFieldChanged == goalNameTextField {
            if goalNameTextField.text == "" {
                // disable the Create Goal button
                createGoalButton.enabled = false
            } else {
                createGoalButton.enabled = true
            }
        }
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, withEvent:event)
    }

}
