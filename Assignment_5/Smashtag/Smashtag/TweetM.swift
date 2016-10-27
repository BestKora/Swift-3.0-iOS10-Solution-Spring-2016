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

    class func tweetWith (twitterInfo: Twitter.Tweet,
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
            tweetM.text = twitterInfo.text
            tweetM.posted = twitterInfo.created as NSDate?
            return tweetM
        }
    }
    
    class func newTweetsWith(twitterInfo: [Twitter.Tweet],
                             andSearchTerm term: String,
                             inContext context: NSManagedObjectContext)
    {
        guard let currentTerm = SearchTerm.termWith(term: term, inContext: context)
                                                                      else {return}
        let newTweetsId = twitterInfo.map {$0.id}
        var newsSet = Set (newTweetsId)
        
        let request: NSFetchRequest<TweetM> = TweetM.fetchRequest()
        request.predicate = NSPredicate(
            format: "any terms.term contains[c] %@ and unique IN %@", term, newsSet)
        
        let results = try? context.fetch(request)
        if let tweets =  results  {
            let oldTweetsId  = tweets.flatMap({ $0.unique})
            let oldsSet = Set (oldTweetsId)
            
            newsSet.subtract(oldsSet)
            print ("-----------кол-во новых элементов \(newsSet.count)-----")
            
            for unique in newsSet {
                if let index = twitterInfo.index(where: {$0.id == unique}){
                    // получаем твит и добавляем терм в terms для этого твита
                    if let tweetM = TweetM.tweetWith (twitterInfo: twitterInfo[index],
                                                        inContext: context){
                            tweetM.terms.insert(currentTerm)
                            // добавляем меншены
                            Mension.mensionsWith(twitterInfo: twitterInfo[index],
                                                 andSearchTerm: currentTerm,
                                                 inContext: context)
                    }
                }
            }
        }
    }
}
