//
//  MOCExtensions.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/19/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext
{
    public func saveThrows () {
        if self.hasChanges {
            do {
                try save()
            } catch let error  {
                let nserror = error as NSError
                print("Core Data Error:  \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
