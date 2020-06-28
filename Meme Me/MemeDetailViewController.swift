//
//  MemeDetailViewController.swift
//  Meme Me
//
//  Created by Justin Kumpe on 6/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
//    MARK: Image View
    @IBOutlet weak var viewImage: UIImageView!
    
//    MARK: Meme Image Index Position
    var memedImageIndex = Int()
    
    //    MARK: Memes Collection
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewImage.image = memes[memedImageIndex].memedImage
    }
}
