//
//  ViewController.swift
//  BJJTV
//
//  Created by BenRussell on 5/1/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let serviceController = BJJTVServiceController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        serviceController.getChannelDetails(false)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refreshData), name: Notification.Name("RefreshTableView"), object: nil)

    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceController.channelsDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)

        let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
        let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
        
        let channelDetails = serviceController.channelsDataArray[indexPath.row]
        
        channelDescriptionLabel.text = channelDetails["description"] as? String
        
        let thumbnailImageString = channelDetails["thumbnail"] as? String
        let loadedImageData = NSData(contentsOf: URL(string: thumbnailImageString!)!)
        if let imageData = loadedImageData {
            thumbnailImageView.image = UIImage(data: imageData as Data)
        }

        
        return cell
    }
    
    func refreshData() {
        self.tableView.reloadData()
    }

}

