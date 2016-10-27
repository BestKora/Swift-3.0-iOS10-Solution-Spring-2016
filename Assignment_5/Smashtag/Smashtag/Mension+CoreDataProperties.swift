//
//  Mension+CoreDataProperties.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
 
extension Mension {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mension> {
        return NSFetchRequest<Mension>(entityName: "Mension");
    }
    
    @NSManaged public var count: NSNumber?
    @NSManaged public var keyword: String?
    @NSManaged public var type: String?
    @NSManaged public var term: SearchTerm?
}
