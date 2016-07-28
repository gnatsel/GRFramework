//
//  GRTableViewController.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 13/11/2015.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Gnatsel Reivilo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import CoreData

@IBDesignable public class GRTableViewController: UITableViewController {

    @IBInspectable public var hasSearchViewController:Bool = false
    @IBInspectable public var defaultCellReuseIdentifier:String = "Cell"

    public var searchController:UISearchController?
    public var fetchedResultsController:NSFetchedResultsController?
    public var dataSource:[[AnyObject]]?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if hasSearchViewController {
            configureSearchController()
        }
        
    }
    
    

    // MARK: - Table view data source
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? dataSource?.count ?? 0
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fetchedResultsController?.sections?[section].numberOfObjects ?? dataSource?[section].count ?? 0
    }

    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(defaultCellReuseIdentifier, forIndexPath: indexPath)
        
        cell.presenter?.configureWithEntity(fetchedResultsController?.objectAtIndexPath(indexPath) ?? dataSource?[indexPath.section][indexPath.row])

        return cell
    }

}

//MARK: NSFetchedResultsControllerDelegate
extension GRTableViewController:NSFetchedResultsControllerDelegate{
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}


//MARK: UISearchResultsUpdating
extension GRTableViewController: UISearchResultsUpdating {
    public func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        guard let searchController = searchController else { return }
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        //Fix the search bar / keyboard not dismissing when a view controller is pushed
        //@see : http://stackoverflow.com/questions/29610873/uisearchcontroller-not-dismissed-when-view-is-pushed
        definesPresentationContext = true;
    }
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {

    }
}
