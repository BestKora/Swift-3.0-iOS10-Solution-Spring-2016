//
//  Mension+CoreDataClass.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 10/18/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

public class Mension: NSManagedObject {
    class func addMension(keyword: String,
                                     andType type: String,
                                     andTerm term:SearchTerm,
                                 andTweetM tweetM:TweetM,
                   inContext context: NSManagedObjectContext) -> Mension?
    {
        guard term.term.characters.count > 0 else { print (" отклонено \(term)"); return nil}
        let request: NSFetchRequest<Mension> = Mension.fetchRequest()
        request.predicate = NSPredicate(format: "keyword  LIKE[cd] %@ AND term.term = %@", keyword, term.term)
        
        if let mentionM = (try? context.fetch(request))?.first {
      // нашли этот меншен в базе данных, count + 1, возвращаем его ...
            
            if !mentionM.tweetMs.contains(tweetM) {
                mentionM.tweetMs.insert(tweetM)
                mentionM.count = NSNumber(value:mentionM.count.intValue + 1)
            }
            return mentionM
        } else    {
             // создаем новый меншен в базе данных и наполняем его информацией ...
            let mentionM = Mension(context: context)
            mentionM.keyword = keyword
            mentionM.type = type
            mentionM.term = term
            mentionM.count = 1
                
            if !mentionM.tweetMs.contains(tweetM) {
                mentionM.tweetMs.insert(tweetM)}
            return mentionM
        }
    }
    
    class func mensionsWith(twitterInfo: Twitter.Tweet,
                                       andTweetM tweetM:TweetM,
                                       andSearchTerm term: SearchTerm,
                                       inContext context: NSManagedObjectContext)
    {
        let hashtags = twitterInfo.hashtags
        for hashtag in hashtags{
            _ = Mension.addMension(keyword: hashtag.keyword,
                                              andType: "Hashtags", andTerm: term, andTweetM:tweetM,
                                              inContext: context)
        }
        let users = twitterInfo.userMentions
        for user in users {
            _ =  Mension.addMension(keyword: user.keyword, andType: "Users", andTerm: term,andTweetM:tweetM,
                                               inContext: context)
        }
        // Для пользователя твита
        let userScreenName = "@" + twitterInfo.user.screenName
        _ =  Mension.addMension(keyword: userScreenName, andType: "Users", andTerm: term, andTweetM:tweetM,
                                           inContext: context)
    }
    
}
