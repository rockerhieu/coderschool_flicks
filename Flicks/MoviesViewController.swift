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

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var movies: [JSON]?
    var endpoint: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        loadMovies()
    }

    func loadMovies() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Alamofire.request(.GET, Settings.apiRoot + endpoint!, parameters: ["api_key": Settings.apiKey])
            .validate().responseJSON { response in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        self.movies = json["results"].array
                        self.tableView.reloadData()
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title = movie["title"].string
        let overview = movie["overview"].string
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        if let posterPath = movie["poster_path"].string {
            let imageUrl = NSURL(string: Settings.endpointImage + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        } else {
            cell.posterView.setImageWithURL(NSURL())
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let movieViewController = segue.destinationViewController as! MovieViewController
        movieViewController.movie = movie
    }

}
