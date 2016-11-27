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
    
    @IBOutlet var goalsTableView: UITableView!
    
 //   @IBOutlet weak var blurringView: UIView!
    
    @IBAction func editing(sender: UIBarButtonItem) {
        self.editing = !self.editing
        appDelegate.saveContext()
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Goal")
        //fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true)
        //fetchRequest.predicate = NSPredicate(format: "numTimesFound > 0")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    var goalsAreMoving: Bool = false
    
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
 
//        let blurEffect = UIBlurEffect(style: .ExtraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = blurringView.frame
//        
//        blurringView.insertSubview(blurEffectView, atIndex: 0)
        
    }
    
    //MARK: - Verifying valid order
    //(in theory should never get out of order, but just in case)
    // checks that all goals have an order value. Would be good to check that all values are unique, and don't skip
    func validateOrder() {
        for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
            if goal.order == nil {
                resetGoalOrder()
                return // there is at least 1 goal without an order value, so reset them all
            }
        }
    }
    
    // helper to set a valid order of goals, if there is one or more that don't have an order value
    func resetGoalOrder() {
        if let numGoals = fetchedResultsController.fetchedObjects?.count {
            for i in 0 ..< numGoals {
                if let goal = fetchedResultsController.fetchedObjects![i] as? Goal {
                    goal.order = i + 1
                }
            }
        }
        appDelegate.saveContext()
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
            
            cell.textLabel?.text = goal.name
            
        }
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
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                goalsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath, let cell = goalsTableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
//            if let indexPath = indexPath {
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            }
//            
//            if let newIndexPath = newIndexPath {
//                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
//            }
            break;
        }
    }
    
    
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
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let goal = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            managedObjectContext.insertObject(goal)
        }    
    }
    

    
    
    // Override to support rearranging the table view.
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        goalsAreMoving = true
        // TODO: - put a dispatch async here, to make sure all moves are done before setting goalsAreMoving to false?
        // Fetch Records
        let goalFromRow = fetchedResultsController.objectAtIndexPath(fromIndexPath) as! Goal
        let goalToRow = fetchedResultsController.objectAtIndexPath(toIndexPath) as! Goal
        
        let tempFrom = goalFromRow.order?.integerValue
        let tempTo = goalToRow.order?.integerValue

        let n = tempTo! - tempFrom!
        
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
    
    // To allow the editing button to work in a generic view controller (not needed in a TableViewController)
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        goalsTableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createGoal" {
            if let destination = segue.destinationViewController as? GoalViewController {
                // send the current # of fetched objects to use in setting the initial order # for the new object
                destination.goalOrder = fetchedResultsController.fetchedObjects?.count
            }
        } else {
            
            if let destination = segue.destinationViewController as? TasksViewController {
                if let indexPath = goalsTableView.indexPathForSelectedRow {
                    destination.currentGoal = fetchedResultsController.objectAtIndexPath(indexPath) as? Goal
                }
            }
        }
    }
    
    // MARK:  Unwind segue
    @IBAction func cancelToGoalsViewController(segue:UIStoryboardSegue) {
    }

}