//
//  BJJTVVideoListViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/2/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class BJJTVVideoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWait: UIView!
    let serviceController = BJJTVServiceController.sharedInstance
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(BJJTVVideoListViewController.refreshData), name: Notification.Name("RefreshTableView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BJJTVVideoListViewController.hideSpinner), name: Notification.Name("HideSpinner"), object: nil)
        
        // Remove all existing video details from the videosArray array.
        serviceController.videosArray.removeAll(keepingCapacity: false)
        
        // Fetch the video details for the tapped channel.
        serviceController.getVideosForChannelAtIndex(index: selectedIndex)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceController.videosArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath)
        
        let videoTitle = cell.viewWithTag(11) as! UILabel
        let videoThumbnail = cell.viewWithTag(12) as! UIImageView
        
        let videoDetails = serviceController.videosArray[indexPath.row]
        videoTitle.text = videoDetails["title"] as? String
        let thumbnailImageString = videoDetails["thumbnail"] as? String
        let loadedImageData = NSData(contentsOf: URL(string: thumbnailImageString!)!)
        if let imageData = loadedImageData {
            videoThumbnail.image = UIImage(data: imageData as Data)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "playVideoSegue", sender: self)
        
    }
    
    func refreshData() {
        self.tableView.reloadData()
    }
    
    func hideSpinner() {
        self.viewWait.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideoSegue" {
            let playerViewController = segue.destination as! BJJTVVideoViewController
            playerViewController.videoID = serviceController.videosArray[selectedIndex]["videoID"] as! String
        }
    }
    
}
