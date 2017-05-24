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
    var desiredChannelsArray = ["GracieBreakdown", "chewybjj", "ralphgracie", "GracieAcademy", "Budovideosdotcom", "jjitsubrotherhood", "StephanKesting"]
    var channelIndex = 0
    var videosArray: Array<Dictionary<String, AnyObject>> = []
    var channelsDataArray: Array<Dictionary<String, AnyObject>> = []
    
    class var sharedInstance : BJJTVServiceController {
        struct Static {
            static let instance : BJJTVServiceController = BJJTVServiceController()
        }
        return Static.instance
    }
    
    func performGetRequest(targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int?, _ error: Error?) -> Void) {
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                completion(nil, nil, error)
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            })
        })
        
        task.resume()
    }
    
    func getChannelDetails(_ useChannelIDParam: Bool, completion: @escaping (Error?) -> Void) {
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
                do {
                    let resultDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
                    if let items = (resultDict as AnyObject).value(forKey: "items") as? NSArray  {
                        
                        if let firstItemDict = items[0] as? Dictionary<String, AnyObject> {
                            let snippetDict = firstItemDict["snippet"] as! Dictionary<String, AnyObject>
                            
                            var desiredValuesDict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                            desiredValuesDict["title"] = snippetDict["title"]
                            desiredValuesDict["description"] = snippetDict["description"]
                            desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            
                            desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<String, AnyObject>)["relatedPlaylists"] as! Dictionary<String, AnyObject>)["uploads"]
                            
                            self.channelsDataArray.append(desiredValuesDict)
                            
                            NotificationCenter.default.post(name: Notification.Name("RefreshTableView"), object: nil)

                            self.channelIndex += 1
                            if self.channelIndex < self.desiredChannelsArray.count {
                                self.getChannelDetails(useChannelIDParam, completion: { (error: Error?) -> Void in
                                    
                                })
                            }
                            else {
                                NotificationCenter.default.post(name: Notification.Name("HideSpinner"), object: nil)
                            }
                        }
                        
                    }
                }
                catch let error as NSError {
                    print("Found an error - \(error)")
                }
                
            }
            else {
                if let status = HTTPStatusCode {
                    print("HTTP Status Code = \(status)")
                }
                print("Error while loading channel details: \(String(describing: error))")
                completion(error)
            }
        })
    }

    
    func getVideosForChannelAtIndex(index: Int!, completion: @escaping (Error?) -> Void) {

        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)&maxResults=20"
        
        let targetURL = URL(string: urlString)
        
        performGetRequest(targetURL: targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
               
                do { let resultsDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
                    
                    if let items = (resultsDict as AnyObject).value(forKey: "items") as? NSArray  {
                        
                        for i in 0 ..< items.count {
                            let playlistSnippetDict = (items[i] as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                            
                            var desiredPlaylistItemDataDict = Dictionary<String, AnyObject>()
                            
                            desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                            desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                            desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                            
                            self.videosArray.append(desiredPlaylistItemDataDict)
                            
                            NotificationCenter.default.post(name: Notification.Name("RefreshTableView"), object: nil)
                        }
                    }
                }
                catch let error as NSError {
                    print("Found an error - \(error)")
                }
            }
            else {
                print("HTTP Status Code = \(String(describing: HTTPStatusCode))")
                print("Error while loading channel details: \(String(describing: error))")
                completion(error)
            }
            
            NotificationCenter.default.post(name: Notification.Name("HideSpinner"), object: nil)
        })
    }

}
