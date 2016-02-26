//
//  File.swift
//  Flickr
//
//  Created by ev_mac16 on 25/02/16.
//  Copyright © 2016 ev_mac16. All rights reserved.
//

import Foundation
import UIKit
import FlickrKitFramework

class LoginViewController: UIViewController {
    
    
    @IBAction func authButtonPressed(sender: AnyObject) {

        self.performSegueWithIdentifier("SegueToAuth", sender: self)
    }
}