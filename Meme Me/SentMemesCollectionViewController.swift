//
//  SentMemesCollectionViewController.swift
//  Meme Me
//
//  Created by Justin Kumpe on 6/23/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{


//    MARK: Collection View
    @IBOutlet var viewCollection: UICollectionView!
    
//    MARK: Memes Collection
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewCollection.delegate = self
        viewCollection.dataSource = self
        let space:CGFloat = 3.0
         
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
         
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
         
        viewCollection.collectionViewLayout = collectionViewFlowLayout
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        viewCollection.reloadData()
    }
    
//  MARK: Set Number of Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
//    MARK: Build Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let meme = memes[(indexPath as NSIndexPath).row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
//    MARK: Did Select Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc: MemeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        vc.memedImageIndex = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
 
    }

//    MARK: Pressed Add Button
    @IBAction func pressedAdd(){
        performSegue(withIdentifier: "segueMemeEditor", sender: self)
    }
    

    
    
}
