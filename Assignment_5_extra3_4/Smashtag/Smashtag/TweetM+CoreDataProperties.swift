//
//  TweetM+CoreDataProperties.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData

extension TweetM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TweetM> {
        return NSFetchRequest<TweetM>(entityName: "TweetM");
    }

    @NSManaged public var posted: NSDate
    @NSManaged public var text: String
    @NSManaged public var unique: String
    @NSManaged public var mensionsTweetM: Set<Mension>
    @NSManaged public var terms: Set<SearchTerm>

}

// MARK: Generated accessors for mensionsTweetM
extension TweetM {

    @objc(addMensionsTweetMObject:)
    @NSManaged public func addToMensionsTweetM(_ value: Mension)

    @objc(removeMensionsTweetMObject:)
    @NSManaged public func removeFromMensionsTweetM(_ value: Mension)

    @objc(addMensionsTweetM:)
    @NSManaged public func addToMensionsTweetM(_ values: NSSet)

    @objc(removeMensionsTweetM:)
    @NSManaged public func removeFromMensionsTweetM(_ values: NSSet)

}

// MARK: Generated accessors for terms
extension TweetM {

    @objc(addTermsObject:)
    @NSManaged public func addToTerms(_ value: SearchTerm)

    @objc(removeTermsObject:)
    @NSManaged public func removeFromTerms(_ value: SearchTerm)

    @objc(addTerms:)
    @NSManaged public func addToTerms(_ values: NSSet)

    @objc(removeTerms:)
    @NSManaged public func removeFromTerms(_ values: NSSet)

}
