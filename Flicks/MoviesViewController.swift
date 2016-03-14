//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Hieu Rocker on 3/12/16.
//  Copyright © 2016 Hieu Rocker. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    var loadingMoreView:InfiniteScrollActivityView?
    var refreshControl: UIRefreshControl!
    var searchController: UISearchController!
    
    var isMoreDataLoading = false
    var page = 0
    var movies: [JSON]?
    var filteredMovies: [JSON]?
    var endpoint: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        setupErrorView()
        setupRefreshControl()
        setupInfiniteScrollLoadingIndicator()
        setupSearchBar()
        loadMovies(refreshControl)
    }

    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "loadMovies:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func setupInfiniteScrollLoadingIndicator() {
        loadingMoreView = InfiniteScrollActivityView(frame: self.getLoadingMoreViewFrame())
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight * 2;
        tableView.contentInset = insets
    }
    
    func setupErrorView() {
        errorView.hidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("onErrorViewTap:"))
        errorView.addGestureRecognizer(tapGesture)
    }
    
    func onErrorViewTap(sender: AnyObject) {
        loadMovies(refreshControl, pageIndex: page)
    }
    
    func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredMovies = movies?.filter { movie in
            return movie["title"].string!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }

    func loadMovies(refreshControl: UIRefreshControl) {
        loadMovies(refreshControl, pageIndex: 1)
    }

    func loadMovies(refreshControl: UIRefreshControl, pageIndex: Int) {
        page = pageIndex
        errorView.hidden = true
        if (pageIndex == 1) {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        Alamofire.request(.GET, "\(Settings.apiRoot + endpoint!)", parameters: ["api_key": Settings.apiKey, "page": pageIndex])
            .validate().responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let movies = json["results"].array
                        if (self.movies == nil || pageIndex == 1) {
                            self.movies = movies
                        } else {
                            self.movies! += movies!
                        }
                        self.tableView.reloadData()
                        self.errorView.hidden = true
                        self.page = json["page"].int ?? 1
                    }
                    break
                case .Failure(_):
                    self.errorView.hidden = false
                    break
                }
                if (pageIndex == 1) {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                self.loadingMoreView!.stopAnimating()
                refreshControl.endRefreshing()
                self.isMoreDataLoading = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((!searchController.active || searchController.searchBar.text == "") && !isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                loadingMoreView?.frame = getLoadingMoreViewFrame()
                loadingMoreView!.startAnimating()
                loadMovies(refreshControl, pageIndex: page + 1)
            }
        }
    }
    
    func getLoadingMoreViewFrame() -> CGRect {
        return CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies?.count ?? 0
        }
        return self.movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie: JSON
        if searchController.active && searchController.searchBar.text != "" {
            movie = filteredMovies![indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        let title = movie["title"].string
        let overview = movie["overview"].string
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.image = nil
        if let posterPath = movie["poster_path"].string {
            let imageUrl = NSURL(string: Settings.endpointImage + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let movieViewController = segue.destinationViewController as! MovieViewController
        movieViewController.movie = movie
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
