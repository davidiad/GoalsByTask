//
//  GoalsTableViewController.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class GoalsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: Constants
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    //MARK: Vars
    var goalsAreMoving: Bool = false
    
    var numGoals: Int {
        get {
            guard let currentCount = fetchedResultsController.fetchedObjects?.count else {
                // There are no existing goals
                return 0
            }
            return currentCount
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Goal")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //MARK: Outlets
    @IBOutlet var goalsTableView: UITableView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    //MARK: - App lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        validateOrder()
        
        // Pad the bottom of the table view so the toolbar doesn't cover the last cell
        goalsTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0);

        feedbackLabel.text = numGoalsFeedback()
    
    }
    
    //MARK: - Verify valid order
    //(in theory should never get out of order, but just in case)
    // checks that all goals have an order value. 
    // Would be good to check that all values are unique, and don't skip
    func validateOrder() {
        for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
            if goal.order == nil {
                resetGoalOrder()
                return // there is at least 1 goal without an order value, so reset them all
            }
        }
    }
    
    // helper to set a valid order of goals, if there is one or more that doesn't have an order value
    func resetGoalOrder() {
        if let numGoals = fetchedResultsController.fetchedObjects?.count {
            for i in 0 ..< numGoals {
                if let goal = fetchedResultsController.fetchedObjects![i] as? Goal {
                    goal.order = i + 1
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.saveContext()
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
            return 3
        }
        return numRows
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("goalcell", forIndexPath: indexPath)
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath: NSIndexPath) {
        if let goal = fetchedResultsController.objectAtIndexPath(atIndexPath) as? Goal {
            if let goalcell = cell as? GoalCell {
                
                let newOrder = atIndexPath.row + 1
                goalcell.priority.text = String(newOrder)
                goalcell.goalname.text = goal.name
            }
            
        }
    }
    
    // MARK:- Table View editing
    
    // To allow the editing button to work in a generic view controller (not needed in a TableViewController)
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        goalsTableView.setEditing(editing, animated: animated)
    }
    
    // De/activate the edit button for the table
    @IBAction func editing(sender: UIBarButtonItem) {
        self.editing = !self.editing
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.saveContext()
        }
    }
    
    // MARK:- Table View delegate
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Fetch Record
            let goal = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            // Delete Record
            managedObjectContext.deleteObject(goal)
            dispatch_async(dispatch_get_main_queue()) {
                self.appDelegate.saveContext() // swipe to delete doesn't save the deletion otherwise
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let goal = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            managedObjectContext.insertObject(goal)
            dispatch_async(dispatch_get_main_queue()) {
                self.appDelegate.saveContext()
            }
        }
    }
    
    
    // Override to support rearranging the table view.
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        goalsAreMoving = true // flag to not update the table rows in the middle of moving rows
        
        // Fetch Records
        let goalFromRow = fetchedResultsController.objectAtIndexPath(fromIndexPath) as! Goal
        let goalToRow = fetchedResultsController.objectAtIndexPath(toIndexPath) as! Goal
        
        guard let tempFrom = goalFromRow.order?.integerValue else {
            feedbackLabel.text = "No order was set for the goal to move from"
            return
        }
        guard let tempTo = goalToRow.order?.integerValue else {
            feedbackLabel.text = "No order was set for the goal to move to"
            return
        }

        let n = tempTo - tempFrom
        
        // depending on whether or not tempTo < tempFrom, the goals are moved either up by 1 or down by 1
        switch n {
        case let n where n > 0:
            for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
                if goal.order?.integerValue > tempFrom && goal.order?.integerValue <= tempTo {
                    let newOrder = (goal.order?.integerValue)! - 1
                    goal.order = newOrder
                }
            }
        case let n where n < 0:
            // Note: switched < and >, but would be better to not repeat almost identical code
            for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
                if goal.order?.integerValue < tempFrom && goal.order?.integerValue >= tempTo {
                    let newOrder = (goal.order?.integerValue)! + 1
                    goal.order = newOrder
                }
            }
        default: break
            // if n = 0, don't move any rows
        }
        
        goalFromRow.order = tempTo
        
        goalsAreMoving = false
        
    }
    

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // MARK:- FetchedResultsController delegate protocol
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if !goalsAreMoving { // flag to avoid updating the table rows in the middle of moving
            goalsTableView.beginUpdates()
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        goalsTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
            
        case .Insert:
            
            if let indexPath = newIndexPath {
                goalsTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                var insertedGoalName = ""
                guard let goal = anObject as? Goal else {
                    insertedGoalName = "A goal"
                    return
                }
                insertedGoalName = goal.name!
                feedbackLabel.text = "\(insertedGoalName) has been added to the goal list" + "\n" + numGoalsFeedback()
            }
            break;
            
        case .Delete:
            if let indexPath = indexPath {
                // save the name of the goal before deleting it (to use in user feedback, below)
                var deletedGoalName = ""
                guard let goal = anObject as? Goal else {
                    deletedGoalName = "A goal"
                    return
                }
                deletedGoalName = goal.name!
                goalsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                
                // update the order (priority) of the cells remaining after the deletion
                for i in indexPath.row ..< numGoals {
                    let nextIndexPath = NSIndexPath(forRow: i, inSection: 0)
                    if let cell = goalsTableView.cellForRowAtIndexPath(nextIndexPath) as? GoalCell {
                        if let goal = fetchedResultsController.fetchedObjects![i] as? Goal {
                            // since order counting is from 1, and index path counting is from 0,
                            // setting to i reduces the order by 1, accounting for the deleted row
                            goal.order = i + 1
                            cell.priority.text = String(goal.order!)
                        }
                    }
                }
                
                feedbackLabel.text = "\(deletedGoalName) has been deleted from the goal list" + "\n" + numGoalsFeedback()
            }
            break;
            
        case .Update:
            if let indexPath = indexPath, let cell = goalsTableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
            
        case .Move:
            // when the order is being edited by user, the cell is moved, so update the cell to match the new order
            if let indexPath = indexPath, let cell = goalsTableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        }
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createGoal" {
            if let destination = segue.destinationViewController as? GoalViewController {
                // send the current # of fetched objects to use in setting the initial order # for the new object
                destination.goalOrder = numGoals + 1 // add the new goal to the end of the list
            }
        } else {
            
            if let destination = segue.destinationViewController as? TasksViewController {
                if let indexPath = goalsTableView.indexPathForSelectedRow {
                    destination.currentGoal = fetchedResultsController.objectAtIndexPath(indexPath) as? Goal
                }
            }
        }
    }
    
    // Unwind segue from Create Goal view controller
    @IBAction func cancelToGoalsViewController(segue:UIStoryboardSegue) {
       
    }
    
    // MARK:- Helper function for feedback
    func numGoalsFeedback () -> String {
        if numGoals == 1 {
            return "You have \(numGoals) goal in your list"
        } else {
            return "You have \(numGoals) goals in your list"
        }
    }

}