//
//  SentMemesTableViewController.swift
//  Meme Me
//
//  Created by Justin Kumpe on 6/23/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
/*    MARK: Refresh Control
     Adds functionality to swipe down to refresh table
 */
    private let refreshControl = UIRefreshControl()
    
//    MARK: Table View
    @IBOutlet var viewTable: UITableView!
    
//    MARK: Memes Collection
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Sent Memes")
        viewTable.reloadData()
    }
    
//    MARK: Set Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
//    MARK: Build Table Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meme = memes[(indexPath as NSIndexPath).row]
        let title = meme.topText + " " + meme.bottomText
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell")!
        
        cell.textLabel?.text = title
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
//    MARK: Set Table Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 127.0
     }
    
//    MARK: Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: MemeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        vc.memedImageIndex = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    MARK: Pressed Add Button
    @IBAction func pressedAdd(_ sender: Any) {
        performSegue(withIdentifier: "segueMemeEditor", sender: self)
    }
    
//    MARK: Swipe to Delete Function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    MARK: Refresh Table
    @objc func refreshTable(){
        viewTable.reloadData()
        refreshControl.endRefreshing()
    }
}
