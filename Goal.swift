//
//  Goal.swift
//  GoalsByTask
//
//  Created by David Fierstein on 10/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData


class Goal: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var order: NSNumber?
    @NSManaged var tasks: NSSet?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(name: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Goal", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        self.name = name

    }
}
