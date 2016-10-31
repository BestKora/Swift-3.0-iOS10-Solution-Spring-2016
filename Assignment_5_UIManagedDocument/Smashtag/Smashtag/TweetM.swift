//
//  TweetM.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class TweetM: NSManagedObject {

    class func tweetWithTwitterInfo(_ twitterInfo: Twitter.Tweet,
                                    inContext context: NSManagedObjectContext) -> TweetM?
    {
      //  let request = NSFetchRequest<TweetM>(entityName: "TweetM")
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweetM = (try? context.fetch(request))?.first {
            // found this tweet in the database, return it ...
            return tweetM
        } else if let tweetM = NSEntityDescription.insertNewObject(forEntityName: "TweetM",
                                                            into: context) as? TweetM {
            // created a new tweet in the database
            // load it up with information from the Twitter.Tweet ...
            tweetM.unique = twitterInfo.id
            tweetM.text   = twitterInfo.text
            tweetM.posted = twitterInfo.created as NSDate
            return tweetM
        }
        return nil
    }
    
    class func tweetWithTwitterInfo(_ twitterInfo: Twitter.Tweet,
                                    andSearchTerm term: String,
                                    inContext context: NSManagedObjectContext) -> TweetM?
    {
      //  let request = NSFetchRequest<TweetM>(entityName: "TweetM")
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique = %@", term,  twitterInfo.id)
        
        if let tweetM = (try? context.fetch(request))?.first {
            // если нашли твит в базе данных, возвращаем его ...
            return tweetM
        } else {
            // получаем твит, получаем терм и добавляем терм в terms для этого твита

            if let tweetM = TweetM.tweetWithTwitterInfo(twitterInfo, inContext: context),
               let currentTerm = SearchTerm.termWithTerm(term, inContext: context) {
                
                let terms = tweetM.mutableSetValue(forKey: "terms")
                terms.add(currentTerm)
                
            // добавляем меншены
            Mension.mensionsWithTwitterInfo(twitterInfo,
                                            andSearchTerm: term,
                                            inContext: context)
            }
        }
        
        return nil
    }
    
    class func newTweetsWithTwitterInfo(_ twitterInfo: [Twitter.Tweet],
                                        andSearchTerm term: String,
                                        inContext context: NSManagedObjectContext)
    {
        //  let request = NSFetchRequest<TweetM>(entityName: "TweetM")
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        let newTweetsId = twitterInfo.map {$0.id}
        var newsSet = Set (newTweetsId)
        
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique IN %@", term, newsSet)
        
        let results = try? context.fetch(request)
        if let tweets =  results  {
            let oldTweetsId = tweets.flatMap({ $0.unique})
            let oldsSet = Set (oldTweetsId)
            
            newsSet.subtract(oldsSet)
            print ("кол-во новых элементов \(newsSet.count)")
            
            for unique in newsSet {
                if let index = twitterInfo.index(where: {$0.id == unique}){
                    // получаем твит, получаем терм и добавляем терм в terms для этого твита
                    
                    if let tweetM = TweetM.tweetWithTwitterInfo(twitterInfo[index],
                                                                inContext: context),
                        let currentTerm = SearchTerm.termWithTerm(term,
                                                                inContext: context){
                        let terms = tweetM.mutableSetValue(forKey: "terms")
                        terms.add(currentTerm)
                        
                        // добавляем меншены
                        Mension.mensionsWithTwitterInfo(twitterInfo[index],
                                                        andSearchTerm: term,
                                                        inContext: context)
                    }
                }
            }
        }
    }
}
