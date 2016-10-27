//
//  SearchTerm.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData

class SearchTerm: NSManagedObject {
    
    class func termWith(term: String,
                            inContext context: NSManagedObjectContext) -> SearchTerm?
    {
        let request: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
        request.predicate = NSPredicate(format: "term = %@", term)
        if let searchTerm = (try? context.fetch(request))?.first {
            return searchTerm
        } else {
            // создаем новую поисковую строку с текстом term...
            let searchTerm = SearchTerm(context: context)
            searchTerm.term = term
            return  searchTerm
        }
    }
    
    override public func prepareForDeletion() {
        if  mensions.count > 0 {
            for mension in mensions {
                managedObjectContext?.delete(mension)
            }
        }
        if  tweets.count > 0 {
            for tweet in tweets {
                if    tweet.terms.filter ({ !($0 as AnyObject).isDeleted }).isEmpty {
                    managedObjectContext?.delete(tweet)
                }
            }
        }
    }
}
