//
//  FeedViewController.swift
//  Parstagram
//
//  Created by KimlyT. on 11/17/19.
//  Copyright © 2019 KimlyT. All rights reserved.
//

import UIKit
import Parse
import Alamofire

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        
        query.includeKeys(["author", "commets", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in       //fetching the posts
            if posts != nil{
                self.posts = posts!                             //store posts in the array
                self.tableView.reloadData()                     //reload the posts on tableView
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        return comments.count + 1 // number of row
        
        
    }
    
    /* Create a section to print both the posts and comments. Each section has a number of row. Two dimentional array */
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //number of section
    }
    
    /* view post, caption and comment on the screen */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user = post["author"] as! PFUser
            
            cell.userNameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["comment"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        
    }
     /* adding comments to a post*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.row]
        let comment = PFObject(className: "Comments")
        
        comment["text"] = "random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comment")
        
        post.saveInBackground { (success, error) in
            if success{
                print("Comment saved!")
            }else{
                print("Error comment did not saved!")
            }
        }
        
    }
    
    /* When click on Logout button, clear the PFU user ans switch to Login screen */
       @IBAction func onLogout(_ sender: Any) {
           
           PFUser.logOut()
           
           let main = UIStoryboard(name: "Main", bundle: nil)
           let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
           
           let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate // declare delegate to acess window
           
           delegate.window?.rootViewController = loginViewController
           
       }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
