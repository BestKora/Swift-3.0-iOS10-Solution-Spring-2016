//
//  PopularityTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class PopularityTableViewController: CoreDataTableViewController {

    // MARK: Model
    
    var searchText: String? { didSet { updateUI() } }
    var moc: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        if let context = moc, let search = searchText, search.characters.count > 0 {
            
            let request: NSFetchRequest<NSFetchRequestResult> = Mension.fetchRequest()
            request.predicate = NSPredicate(format:
                "term.term contains[c] %@ AND count > %@", searchText!, "1")
            request.sortDescriptors = [NSSortDescriptor(
                key: "type",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ), NSSortDescriptor(
                    key: "count",
                    ascending: false
                ),NSSortDescriptor(
                    key: "keyword",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            fetchedResultsController =
                NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: "type",
                    cacheName: nil
            )
        } else {
            fetchedResultsController = nil
        }
    }
    
    private struct Storyboard {
        static let CellIdentifier = "PopularMentionsCell"
        static let SegueToMainTweetTableView = "ToMainTweetTableView"
    }
    // MARK: UITableViewDataSource
    
    
     override func tableView(_ tableView: UITableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier,
                                                                         for: indexPath)
        var keyword: String?
        var count: String?
        if let mensionM = fetchedResultsController?.object(at: indexPath) as? Mension {
            mensionM.managedObjectContext?.performAndWait {  // asynchronous
                keyword =  mensionM.keyword
                count =  mensionM.count?.stringValue
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
        }
     return cell
     }
    
    
    @IBAction private func toRootViewController(_ sender: UIBarButtonItem) {
        
       _ = navigationController?.popToRootViewController(animated: true)
    }

   
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == Storyboard.SegueToMainTweetTableView{
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {text += " OR from:" + text}
                    ttvc.searchText = text
                }
            }
        }
    }
}
