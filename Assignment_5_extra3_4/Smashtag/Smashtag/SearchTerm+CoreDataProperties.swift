//
//  SearchTerm+CoreDataProperties.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData

extension SearchTerm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchTerm> {
        return NSFetchRequest<SearchTerm>(entityName: "SearchTerm");
    }

    @NSManaged public var term: String
    @NSManaged public var mensions: NSSet
    @NSManaged public var tweets: NSSet

}

// MARK: Generated accessors for mensions
extension SearchTerm {

    @objc(addMensionsObject:)
    @NSManaged public func addToMensions(_ value: Mension)

    @objc(removeMensionsObject:)
    @NSManaged public func removeFromMensions(_ value: Mension)

    @objc(addMensions:)
    @NSManaged public func addToMensions(_ values: NSSet)

    @objc(removeMensions:)
    @NSManaged public func removeFromMensions(_ values: NSSet)

}

// MARK: Generated accessors for tweets
extension SearchTerm {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: TweetM)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: TweetM)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}
