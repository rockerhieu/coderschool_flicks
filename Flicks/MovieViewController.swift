//
//  MovieViewController.swift
//  Flicks
//
//  Created by Hieu Rocker on 3/13/16.
//  Copyright © 2016 Hieu Rocker. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MovieViewController: UIViewController {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!

    var movie: JSON!
    
    override func viewDidLoad() {
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        let title = movie["title"].string
        let overview = movie["overview"].string
        titleView.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        if let posterPath = movie["poster_path"].string {
            let imageUrl = NSURL(string: Settings.endpointImage + posterPath)
            posterView.setImageWithURL(imageUrl!)
        } else {
            posterView.setImageWithURL(NSURL())
        }
    }
}
