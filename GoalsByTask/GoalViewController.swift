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
//        guard let newGoalName = goalNameTextField.text else {
//            _ = Goal(name: "my new mane", context: managedObjectContext)
//        }
        let newGoal = Goal(name: newGoalName!, context: managedObjectContext)
        newGoal.order = goalOrder
//        _ = NSEntityDescription.insertNewObjectForEntityForName("Goal", inManagedObjectContext: managedObjectContext) as! Goal
        
        appDelegate.saveContext()
        //TODO: NEED DIspatch async call to make sure context save is complete before dismissing VC?
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(goalOrder)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
