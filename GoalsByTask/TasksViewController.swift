//
//  TasksViewController.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // vars to hold data to pass back to parent view controller
    var goalNameEdited: String?
    var numTasksAdded: Int = 0
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBOutlet weak var goalName: UITextField!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var addTaskButton: UIButton!
    @IBAction func createTask(sender: AnyObject) {
        
        view.endEditing(true) // dismiss the keyboard
        
        guard let newTaskName = taskNameTextField.text else {
            feedbackLabel.text = "Please give the task a name before adding it"
            return
        }
        
        if newTaskName == "" {
            feedbackLabel.text = "Please name the task before adding it to the list"
        } else {
            let newTask = Task(name: newTaskName, context: managedObjectContext)
            newTask.goal = currentGoal
            dispatch_async(dispatch_get_main_queue()) {
                self.appDelegate.saveContext()
            }
            
            feedbackLabel.text = ("\(newTaskName) has been added to the task list")
            taskNameTextField.text = "" // reset the textfield to blank after the task has been added to list
            addTaskButton.enabled = false // Disable button because textfield is now empty again
            numTasksAdded += 1
        }
    }
    
    var currentGoal: Goal?
    let goalTextFieldDelegate = GoalTextFieldDelegate()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goal == %@", self.currentGoal!)
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //MARK: - App lifecycle
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        navigationController?.delegate = self // to allow passing data back to parent VC
        goalName.delegate = goalTextFieldDelegate
        goalName.text = currentGoal?.name
        
        taskNameTextField.delegate = self
        taskNameTextField.layer.borderColor = UIColor( red: 252/255, green: 106/255, blue:8/255, alpha: 1.0 ).CGColor
        taskNameTextField.layer.borderWidth = 2.0
              
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(textFieldDidChange(_:)),
                                       name: UITextFieldTextDidChangeNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(saveNameChange),
                                       name: saveNameChangeNotificationKey,
                                       object: nil)
        
    }
    
    //MARK:- Textfield delegate methods
    func textFieldDidChange(sender : AnyObject) {
        if let notification = sender as? NSNotification,
            textFieldChanged = notification.object as? UITextField
            where textFieldChanged == taskNameTextField {
            if taskNameTextField.text == "" {
                // disable the Create Task button
                addTaskButton.enabled = false
            } else {
                addTaskButton.enabled = true
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        textField.adjustsFontSizeToFitWidth = true
        textField.borderStyle = UITextBorderStyle.Bezel
        // While editing, set a background color for the text, so the user has a cue that they are editing text
        textField.backgroundColor = UIColor(hue: 0.1, saturation: 0.09, brightness: 1.0, alpha: 1.0)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.borderStyle = UITextBorderStyle.None
        // Get rid of the bg color when done editing
        textField.backgroundColor = UIColor.whiteColor()
    }
    
    //MARK:-
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? GoalsTableViewController {
            // pass data back to parent VC.
            // goalNameEdited should be nil if the goal name was not changed
            var feedbackLine1 = ""
            var feedbackLine2 = ""
            if goalNameEdited != nil {
                feedbackLine1 = "The goal is now: \(goalNameEdited!)"
            } else {
                feedbackLine1 = "The goal: \((currentGoal?.name)!)"
            }
            if numTasksAdded > 0 {
                var pluralize = "tasks have"
                if numTasksAdded == 1 {
                    pluralize = "task has"
                }
                feedbackLine2 = "\(String(numTasksAdded)) \(pluralize) been added to the goal"
            }
            controller.feedbackLabel.text = feedbackLine1 + "\n" + feedbackLine2
        }
    }
    
    // MARK: - Unwind segue
    @IBAction func cancelToGoalsViewController(segue:UIStoryboardSegue) {
    }
    
    // MARK: - Textfield editing
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      
            view.endEditing(true)

        super.touchesBegan(touches, withEvent:event)
    }
    
    // Dismiss keyboard when tapping Return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Core Data
    
    func saveNameChange() {
        if currentGoal != nil {
            if goalName.text == "" {
                feedbackLabel.text = "Please don't leave the Goal name blank"
                // if the goal name was blank, replace it with the current name
                if currentGoal != nil {
                    goalName.text = currentGoal?.name
                }
                
            } else {
                currentGoal?.name = goalName.text
                dispatch_async(dispatch_get_main_queue()) {
                    self.appDelegate.saveContext()
                }
                feedbackLabel.text = "The goal is now: \((currentGoal?.name)!)"
                // save the data to pass back to parent view controller
                goalNameEdited = goalName.text
            }
        } else {
            feedbackLabel.text = "There is no current goal"
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let _ = fetchedResultsController.sections else {
            return 0
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numRows = fetchedResultsController.fetchedObjects?.count else {
            return 6
        }
        return numRows
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskcell", forIndexPath: indexPath)
        
        if let task = fetchedResultsController.objectAtIndexPath(indexPath) as? Task {
            
            cell.textLabel?.text = task.name
            
            
        }
        return cell
    }
    
    // MARK:- FetchedResultsController delegate protocol
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tasksTableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tasksTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tasksTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tasksTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            break;
        case .Move:
            if let indexPath = indexPath {
                tasksTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tasksTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }

}
