//
//  TweetM+CoreDataClass.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter


public class TweetM: NSManagedObject {
    class func tweetWith(twitterInfo: Twitter.Tweet,
                                    inContext context: NSManagedObjectContext) -> TweetM?
    {
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweetM = (try? context.fetch(request))?.first {
                return tweetM
        } else {
          // создаем новый твит и наполняем его информацией из Twitter.Tweet ...
            let tweetM = TweetM(context: context)
            tweetM.unique = twitterInfo.id
            tweetM.text   = twitterInfo.text
            tweetM.posted = (twitterInfo.created as NSDate?)!
            return tweetM
        }
    }
    
    class func tweetWith(twitterInfo: Twitter.Tweet,
                         andSearchTerm term: String,
                          inContext context: NSManagedObjectContext) -> TweetM?
    {
        guard let currentTerm = SearchTerm.termWith(term: term, inContext: context) else {return nil}
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique = %@", term,  twitterInfo.id)
        
        if let tweetM = (try? context.fetch(request))?.first {
            // если нашли твит в базе данных, возвращаем его ...
            return tweetM
        } else {
            // получаем твит и добавляем терм в terms для этого твита
            if let tweetM = TweetM.tweetWith(twitterInfo: twitterInfo, inContext: context)
            {
                if !tweetM.terms.contains(currentTerm) {
                    tweetM.terms.insert(currentTerm)
                    
                    // добавляем меншены
                    Mension.mensionsWith(twitterInfo: twitterInfo, andTweetM:tweetM,
                                       andSearchTerm: currentTerm, inContext: context)
                }
            }
        }
        
        return nil
    }
    
    class func newTweetsWith(twitterInfo: [Twitter.Tweet],
                             andSearchTerm term: String,
                             inContext context: NSManagedObjectContext)
    {
        guard let currentTerm = SearchTerm.termWith(term: term, inContext: context) else {return}
        
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        let newTweetsId = twitterInfo.map {$0.id}
        
        var newsSet = Set (newTweetsId)
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique IN %@", term, newsSet )
        let results = try? context.fetch(request)
        if let tweets =  results {
            let oldTweetsId = tweets.flatMap({ $0.unique})
            let oldsSet = Set (oldTweetsId)
            
            newsSet.subtract(oldsSet)
            print ("-----------кол-во новых элементов \(newsSet.count)-----")
            for unique in newsSet {
                if let index = twitterInfo.index(where: {$0.id == unique}){
                    // получаем твит и добавляем терм в terms для этого твита
                    if let tweetM = TweetM.tweetWith(twitterInfo: twitterInfo[index], inContext: context)
                    {
                        tweetM.terms.insert(currentTerm)
                        
                        // добавляем меншены
                        Mension.mensionsWith(twitterInfo: twitterInfo[index], andTweetM:tweetM,
                                             andSearchTerm: currentTerm, inContext: context)
                    }
                }
                
            }
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let TimeToRemoveOldTweets  = -60*60*24*7
    }
    
    class func removeOldTweets(context: NSManagedObjectContext) {
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        let weekAgo = Date(timeIntervalSinceNow: TimeInterval(Constants.TimeToRemoveOldTweets))
        request.predicate = NSPredicate(format: "posted < %@", weekAgo as CVarArg)
        
        let results = try? context.fetch(request)
        if let count = results?.count{
            print ("Убрано \(count) Tweetms")
            /*          for tweet in results! {
             print ("время \(tweet.posted) Tweetms")
             }*/
        }
        if let tweetMs = results  {
            for tweetM in tweetMs {
                context.delete(tweetM)
            }
        }
    }
    
    class func syncTerms(context: NSManagedObjectContext) {
        let requestTerm: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
        var  termsCoreData = [String]()
        let resultsT = try? context.fetch(requestTerm)
        if let results = resultsT,results.count > 0{
       //     print ("В базе осталось \(results.count) Terms")
            for term in results {
                termsCoreData.append(term.term)
       //         print ("term ----- \(term.term)")
            }
        }
        let termsDefaults = RecentSearches.searches
              for term in termsDefaults {
            if let index = RecentSearches.searches.index(where: {$0 == term}){
                RecentSearches.removeAtIndex(index)
            }
        }
       for term in termsCoreData {
        RecentSearches.add(term)
        }
    }
    
    override public func prepareForDeletion() {
        if  mensionsTweetM.count > 0 {
            for mension in mensionsTweetM {
                mension.count = NSNumber (value:mension.count.intValue - 1)
                if mension.count == 0 {
                    managedObjectContext?.delete(mension)
                }
            }
        }
        if  terms.count > 0 {
            for term in terms {
                if    term.tweets.filter ({ !($0 as AnyObject).isDeleted }).isEmpty {
                    managedObjectContext?.delete(term)
                }
            }
        }
        
    }

}
