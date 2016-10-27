//
//  SearchTerm+CoreDataClass.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData


public class SearchTerm: NSManagedObject {
    class func termWith(term: String,
                            inContext context: NSManagedObjectContext) -> SearchTerm?
   {
        let request: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
        request.predicate = NSPredicate(format: "term = %@", term)
        if let searchTerm = (try? context.fetch(request))?.first {
            return searchTerm
        } else {
            let searchTerm = SearchTerm (context: context)
            searchTerm.term = term
            return  searchTerm
        }
    }
}

