//
//  FlickrSearcher.swift
//  flickrSearch
//
//  Created by Richard Turton on 31/07/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import UIKit

let apiKey = "348ea26ca45d5f9d3da7fff4822a7fd1"

struct FlickrSearchResults {
    let searchTerm : String
    var searchResults : [FlickrPhoto]
}

class FlickrPhoto : Equatable {
    var thumbnail : UIImage?
    var largeImage : UIImage?
    var isFliped : Bool?
    let photoID : String
    let farm : Int
    let server : String
    let secret : String
    let title : String
    
    init (photoID:String,farm:Int, server:String, secret:String, title:String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    func flickrImageURL(size:String = "m") -> NSURL {
        return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
    }
    
    func sizeToFillWidthOfSize(size:CGSize) -> CGSize {
        if thumbnail == nil {
            return size
        }
        
        let imageSize = thumbnail!.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        
        return returnSize
    }
    
}

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
    return lhs.photoID == rhs.photoID
}

class Flickr {
    
    let processingQueue = NSOperationQueue()
    
    func searchFlickrForTerm(searchTerm: String, completion : (results: FlickrSearchResults?, error : NSError?) -> Void){
        
        let searchURL = flickrSearchURLForSearchTerm(searchTerm)
        
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(searchURL, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("error: \(error!.localizedDescription): \(error!.userInfo)")
                }
                else if data != nil {
                    if let str = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                        print("Received data:\n\(str)")
                        
                        do {
                            let resultsDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                            
                            
                            switch (resultsDictionary!["stat"] as! String) {
                            case "ok":
                                print("Results processed OK")
                            case "fail":
                                let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary!["message"]!])
                                completion(results: nil, error: APIError)
                                return
                            default:
                                let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                                completion(results: nil, error: APIError)
                                return
                            }
                            
                            let photosContainer = resultsDictionary!["photos"] as! NSDictionary
                            let photosReceived = photosContainer["photo"] as! [NSDictionary]
                            
                            let flickrPhotos : [FlickrPhoto] = photosReceived.map {
                                photoDictionary in
                                
                                print(photoDictionary)
                                
                                let photoID = photoDictionary["id"] as? String ?? ""
                                let farm = photoDictionary["farm"] as? Int ?? 0
                                let server = photoDictionary["server"] as? String ?? ""
                                let secret = photoDictionary["secret"] as? String ?? ""
                                let title = photoDictionary["title"] as? String ?? ""
                                
                                let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret, title: title)
                                
                                let imageData = NSData(contentsOfURL: flickrPhoto.flickrImageURL())
                                flickrPhoto.thumbnail = UIImage(data: imageData!)
                                flickrPhoto.isFliped = false
                                
                                return flickrPhoto
                                
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                completion(results:FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), error: nil)
                            })
                        }catch {
                            print(error)
                        }
                    }
                    else {
                        print("unable to convert data to text")
                    }
                }
            })
            
            task.resume()
}
    
    private func flickrSearchURLForSearchTerm(searchTerm:String) -> NSURL {
        
//        let escapedTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(searchTerm)&per_page=20&format=json&nojsoncallback=1"
        //     let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=348ea26ca45d5f9d3da7fff4822a7fd1&format=json&nojsoncallback=1&text=cats&extras=url_o"
        return NSURL(string: URLString)!
    }
    
    
}
