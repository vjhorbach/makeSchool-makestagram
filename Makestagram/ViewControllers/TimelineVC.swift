//
//  TimelineVC.swift
//  Makestagram
//
//  Created by Vyacheslav Horbach on 24/06/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("users", matchesKey: "toUser", inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser?.whereKey("user", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        
        query.includeKey("user")
        
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock {(result: [PFObject]?, err: NSError?)  -> Void in
        
            self.posts = result as? [Post] ?? []
            
            self.tableView.reloadData()
        }
    }
    
    
    func takePhoto() {
        //intanitate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
            let post = Post()
            post.img = image
            post.uploadPost()
        })
    }
    
}

// MARK: Tab Bar Delegate

extension TimelineVC: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoVC) {
            takePhoto()
            return false
            
        } else {
            print("photo was not taken")
            return true
            
        }
    }
}

extension TimelineVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as UITableViewCell!
        
        cell.textLabel?.text = "Random Post"
        
        return cell
    }
}

























