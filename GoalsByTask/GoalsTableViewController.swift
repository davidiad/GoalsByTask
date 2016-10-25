//
//  GoalsTableViewController.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class GoalsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBAction func editing(sender: UIBarButtonItem) {
        self.editing = !self.editing
        appDelegate.saveContext()
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - NSFetchedResultsController
//    lazy var sharedContext = {
//        CoreDataStackManager.sharedInstance().managedObjectContext
//    }()
    
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
        
    }
    
    //MARK: - Verifying valid order
    
    func validateOrder() {
        for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
            if goal.order == nil {
                resetGoalOrder()
                return // there is at least 1 goal without an order value, so reset them all
                // (in theory whouldn't happen)
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
    
    
    // MARK: - Unwind segue
    @IBAction func cancelToGoalsViewController(segue:UIStoryboardSegue) {
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let _ = fetchedResultsController.sections else {
            return 0
        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numRows = fetchedResultsController.fetchedObjects?.count else {
            return 3
        }
        return numRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("goalcell", forIndexPath: indexPath)

        //let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
        
//        if let goal = fetchedResultsController.objectAtIndexPath(indexPath) as? Goal {
//        
//            cell.textLabel?.text = goal.name
//     
//        }
        
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
        if !goalsAreMoving {
            tableView.beginUpdates()
        }

    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) {
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
    
    
    //MARK:- Table View Data Source Methods
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if let _ = fetchedResultsController.sections {
//            return 1
//        }
//        
//        return 0
//    }
    

    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
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
        
//        for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
//            if goal.order?.integerValue > tempFrom && goal.order?.integerValue <= tempTo {
//                let newOrder = (goal.order?.integerValue)! + incrementAmount
//                goal.order = newOrder
//            }
//        }
        

        
        goalsAreMoving = false
        
        // var movingGoals: [Goal] = fetchedResultsController.fetchedObjects as? [Goal]

        
//        for i in Int(goalFromRow.order!) ..< Int(goalToRow.order!) {
//            movingGoals.append(fetchedResultsController.objectAtIndexPath(i) as Goal)
//        }
        
//        for goal: Goal in fetchedResultsController.fetchedObjects as! [Goal] {
//            
//        }
        
        
        
//       let temp = goalFromRow.order
//        goalFromRow.order = goalToRow.order
//        goalToRow.order = temp
//        managedObjectContext.deleteObject(goalFromRow)
//        managedObjectContext.insertObject(goalToRow)
        

        // from to til from, order -= 1
        
        
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createGoal" {
            if let destination = segue.destinationViewController as? GoalViewController {
                // send the current # of fetched objects to use in setting the initial order # for the new object
                destination.goalOrder = fetchedResultsController.fetchedObjects?.count
            }
        } else {
            
        //if segue.identifier == "goalDetail" {
            if let destination = segue.destinationViewController as? TasksViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destination.currentGoal = fetchedResultsController.objectAtIndexPath(indexPath) as? Goal
                }
            }
        }
    }
    
 

}
