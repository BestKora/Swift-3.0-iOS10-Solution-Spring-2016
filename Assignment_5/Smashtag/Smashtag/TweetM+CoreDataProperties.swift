//
//  TweetM+CoreDataProperties.swift
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

extension TweetM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TweetM> {
        return NSFetchRequest<TweetM>(entityName: "TweetM");
    }
    
    @NSManaged public var posted: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var unique: String
    @NSManaged public var terms: Set<SearchTerm>
}

