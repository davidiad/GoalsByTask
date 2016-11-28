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
    

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let goalTextFieldDelegate = GoalTextFieldDelegate()

    var goalOrder: Int?
    
    @IBOutlet weak var goalNameTextField: UITextField!
    @IBOutlet weak var feedbackLabel: UILabel!
    
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
            
            appDelegate.saveContext()
            //TODO: dispatch async call to make sure context save is complete before dismissing VC?
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalNameTextField.delegate = goalTextFieldDelegate
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, withEvent:event)
    }

}
