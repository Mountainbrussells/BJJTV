//
//  BJJTVVideoViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/3/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class BJJTVVideoViewController: UIViewController, YTPlayerViewDelegate {
    
    var videoID: String!
    
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waitView.isHidden = true
        playerView.delegate = self
        playerView.load(withVideoId: videoID)
    }
    
    func playerView(_ playerView:YTPlayerView, didChangeTo didChangeToState:YTPlayerState) {
            print ("\(didChangeToState)")
    }
}
