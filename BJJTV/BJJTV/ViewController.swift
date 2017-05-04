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
    
    let serviceController = BJJTVServiceController.sharedInstance
    var selectedIndex: Int!
    var destinationVC: BJJTVVideoListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        serviceController.getChannelDetails(false)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refreshData), name: Notification.Name("RefreshTableView"), object: nil)
        navigationController?.navigationBar.barTintColor = UIColor.brown
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orange]
        navigationController?.navigationBar.tintColor = UIColor.orange;

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
        
        cell.backgroundView = UIImageView(image: UIImage(named: "blackbelt.png"))
       
        
        let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
        channelDescriptionLabel.layer.cornerRadius = 10
        channelDescriptionLabel.clipsToBounds = true
        let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
        
        let channelDetails = serviceController.channelsDataArray[indexPath.row]
        
        channelDescriptionLabel.text = channelDetails["title"] as? String
        // Update to swift 3
        let thumbnailImageString = channelDetails["thumbnail"] as? String
        let loadedImageData = NSData(contentsOf: URL(string: thumbnailImageString!)!)
        if let imageData = loadedImageData {
            thumbnailImageView.image = UIImage(data: imageData as Data)
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        destinationVC.selectedIndex = indexPath.row
        
    }
    
    func refreshData() {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideosView" {
            destinationVC = segue.destination as! BJJTVVideoListViewController
        }
    }

}

