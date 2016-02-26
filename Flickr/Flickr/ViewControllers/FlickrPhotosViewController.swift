//
//  File.swift
//  Flickr
//
//  Created by ev_mac16 on 25/02/16.
//  Copyright © 2016 ev_mac16. All rights reserved.
//

import UIKit

class FlickrPhotosViewController: UICollectionViewController {
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
    
    override func viewDidLoad() {
        ProgressHUD.shared().show()
        fetchIMages()
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    
    func fetchIMages()
    {
        flickr.searchFlickrForTerm("Nature") {
            results, error in
            
            //2
            if error != nil {
                print("Error searching : \(error)")
            }
            
            if results != nil {
                //3
                print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                
                //4
                self.collectionView?.reloadData()
            }
            ProgressHUD.shared().hide()
        }
    }
}

extension FlickrPhotosViewController {
    
    //1
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print(searches.count)
        return searches.count
    }
    
    //2
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    //3
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //1
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
        //2
        let flickrPhoto = photoForIndexPath(indexPath)
//        cell.backgroundColor = UIColor.blackColor()
        //3
        
        if flickrPhoto.isFliped == false
        {
            cell.imageView.hidden = false
            cell.imageNameLbl.hidden = true
        }
        else if flickrPhoto.isFliped == true
        {
            cell.imageView.hidden = true
            cell.imageNameLbl.hidden = false
        }
        
        cell.imageView.image = flickrPhoto.thumbnail
        cell.imageNameLbl.text = flickrPhoto.title
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        print(indexPath.row)
        let flickrPhoto = photoForIndexPath(indexPath)
        
        let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! FlickrPhotoCell
        
        UIView.transitionWithView(cell.contentView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
            
            if flickrPhoto.isFliped == false
            {
                flickrPhoto.isFliped = true
                cell.imageView.hidden = true
                cell.imageNameLbl.hidden = false
            }
            else if flickrPhoto.isFliped == true
            {
                flickrPhoto.isFliped = false
                cell.imageView.hidden = false
                cell.imageNameLbl.hidden = true
            }
            
            self.searches[indexPath.section].searchResults[indexPath.row] = flickrPhoto
            }, completion: {_ in
                //....transition completion
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                })

        })
    }
    
}

extension FlickrPhotosViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 1
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        flickr.searchFlickrForTerm(textField.text!) {
            results, error in
            
            //2
            activityIndicator.removeFromSuperview()
            if error != nil {
                print("Error searching : \(error)")
            }
            
            if results != nil {
                //3
                print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                
                //4
                self.collectionView?.reloadData()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

            return CGSize(width: (self.collectionView?.bounds.width)!/2-25, height: 100)
    }
    
    //3
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}
