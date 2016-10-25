//
//  TasksViewController.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBOutlet weak var goalName: UITextField!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBAction func createTask(sender: AnyObject) {
        let newTaskName = taskNameTextField.text
        let newTask = Task(name: newTaskName!, context: managedObjectContext)
        newTask.goal = currentGoal
        appDelegate.saveContext()
        
        taskNameTextField.text = ""
    }
    
    var currentGoal: Goal?
    let goalTextFieldDelegate = GoalTextFieldDelegate()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "goal == %@", self.currentGoal!)
        //fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true)
        //fetchRequest.predicate = NSPredicate(format: "numTimesFound > 0")
        
        // Add Sort Descriptors
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
        
        goalName.text = currentGoal?.name
        goalName.delegate = goalTextFieldDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveNameChange), name: saveNameChangeNotificationKey, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Unwind segue
    @IBAction func cancelToGoalsViewController(segue:UIStoryboardSegue) {
    }
    
    //MARK: - Core Data
    
    func saveNameChange() {
        // TODO: what if currentGoal is nil?
        currentGoal?.name = goalName.text
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
            return 6
        }
        return numRows
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskcell", forIndexPath: indexPath)
        
        //let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
        
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
            //            if let indexPath = indexPath, let cell = wordTable.cellForRowAtIndexPath(indexPath) as? WordListCell {
            //                configureCell(cell, atIndexPath: indexPath)
            //            }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
