//
//  BJJTVVideoViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/3/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class BJJTVVideoViewController: UIViewController {
    
    var videoID: String!
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.load(withVideoId: videoID)
    }
}
