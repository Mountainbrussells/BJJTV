//
//  BJJTVServiceController.swift
//  BJJTV
//
//  Created by BenRussell on 5/1/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import Foundation

class BJJTVServiceController: NSObject {
    var apiKey = "AIzaSyAS0nysNf7f1gB3WCOnAPd_aJ7uTlCJHoM"
    var desiredChannelsArray = ["GracieBreakdown"]
    var channelIndex = 0
    var videosArray: Array<Dictionary<String, AnyObject>> = []
    var channelsDataArray: Array<Dictionary<String, AnyObject>> = []
    
    func performGetRequest(targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            })
        })
        
        task.resume()
    }
    
    func getChannelDetails(_ useChannelIDParam: Bool) {
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        else {
            
        }
        
        let targetURL = URL(string: urlString)
        
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // let resultsDict:Dictionary<String, AnyObject>
                // Convert the JSON data to a dictionary.
                do {
                    let resultDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    if let items = (resultDict as AnyObject).value(forKey: "items") as? NSArray  {
                        
                        if let firstItemDict = items[0] as? Dictionary<String, AnyObject> {
                            // Get the snippet dictionary that contains the desired data.
                            let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                            
                            // Create a new dictionary to store only the values we care about.
                            var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                            desiredValuesDict["title"] = snippetDict["title"]
                            desiredValuesDict["description"] = snippetDict["description"]
                            desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            
                            // Save the channel's uploaded videos playlist ID.
                            desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
                            
                            
                            // Append the desiredValuesDict dictionary to the following array.
                            self.channelsDataArray.append(desiredValuesDict)
                            
                            // TODO: Reload the tableview.
                            NotificationCenter.default.post(name: Notification.Name("RefreshTableView"), object: nil)

                            
                            // Load the next channel data (if exist).
                            self.channelIndex += 1
                            if self.channelIndex < self.desiredChannelsArray.count {
                                self.getChannelDetails(useChannelIDParam)
                            }
                            else {
                                // TODO: Hide spinner
                            }
                        }
                        
                    }
                }
                catch let error as NSError {
                    print("Found an error - \(error)")
                }
                
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(String(describing: error))")
            }
        })
    }

    
    func getVideosForChannelAtIndex(index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
        
        // Create a NSURL object based on the above string.
        let targetURL = URL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do { let resultsDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    if let items = (resultsDict as AnyObject).value(forKey: "items") as? NSArray  {
                        
                        // Use a loop to go through all video items.
                        for i in 0 ..< items.count {
                            let playlistSnippetDict = (items[i] as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                            
                            // Initialize a new dictionary and store the data of interest.
                            var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                            
                            desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                            desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                            
                            // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                            self.videosArray.append(desiredPlaylistItemDataDict)
                            
                            // TODO: Reload the tableview.
                            NotificationCenter.default.post(name: Notification.Name("RefreshTableView"), object: nil)
                        }
                    }
                }
                catch let error as NSError {
                    print("Found an error - \(error)")
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(String(describing: error))")
            }
            
            // TODO: Hide the activity indicator.
        })
    }

}
