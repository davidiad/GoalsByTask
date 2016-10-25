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

    var goalOrder: Int?
    
    @IBOutlet weak var goalNameTextField: UITextField!
    
    @IBAction func createGoal(sender: AnyObject) {
        // init a new managed object
        let newGoalName = goalNameTextField.text
        //TODO: - what if no text for the name has been entered?
        let newGoal = Goal(name: newGoalName!, context: managedObjectContext)
        newGoal.order = goalOrder
        
        appDelegate.saveContext()
        //TODO: dispatch async call to make sure context save is complete before dismissing VC?
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, withEvent:event)
    }

}
