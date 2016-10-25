//
//  Task.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {
    
    @NSManaged var name: String?
    @NSManaged var goal: Goal?
//    @NSManaged var lat: NSNumber?
//    @NSManaged var lon: NSNumber?
//    @NSManaged var pinID: NSNumber?
//    @NSManaged var photos: [Photo]
//    @NSManaged var search: Search?
    
    
    // standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Pin class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        self.name = name
        //lon = dictionary[Keys.Lon] as? NSNumber
    }
}
