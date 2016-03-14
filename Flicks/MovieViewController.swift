//
//  MovieViewController.swift
//  Flicks
//
//  Created by Hieu Rocker on 3/13/16.
//  Copyright © 2016 Hieu Rocker. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class MovieViewController: UIViewController {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var popularityView: UILabel!
    @IBOutlet weak var releaseDateView: UILabel!

    var movie: JSON!
    var posterImage: UIImage?
    
    override func viewDidLoad() {
        let title = movie["title"].string
        let overview = movie["overview"].string
        if let popularity = movie["popularity"].double {
            popularityView.text = "\(Int(popularity))%"
        } else {
            popularityView.text = "-"
        }
        if let releaseDateString = movie["release_date"].string {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            releaseDateView.text = formatter.stringFromDate(formatter.dateFromString(releaseDateString)!)
        } else {
            releaseDateView.text = "Unknown"
        }

        titleView.text = title
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        infoView.frame.size = CGSize(width: infoView.frame.width, height: titleView.frame.height + releaseDateView.frame.height + overviewLabel.frame.height + 30)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        posterView.image = posterImage
        if let posterPath = movie["poster_path"].string {
            let imageUrl = Settings.getImageUrl(posterPath, size: 780)
            posterView.af_setImageWithURL(imageUrl, imageTransition: .CrossDissolve(0.2))
        } else {
            posterView.image = nil
        }
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -50
        horizontalMotionEffect.maximumRelativeValue = 50
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -50
        verticalMotionEffect.maximumRelativeValue = 50
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]

        posterView.addMotionEffect(motionEffectGroup)
    }
}
