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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MessageInputBarDelegate {
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false                 //don't show New Message bar by defualt, only when click
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive    //dismiss the keyboard when it's pulled down
        
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)),name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    /* Dismiss the New Message bar once it's done */
      @objc func keyboardWillBeHidden(note: Notification){
          commentBar.inputTextView.text = nil
          showsCommentBar = false
          becomeFirstResponder()
      }
      
    /* Create comment */
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved!")
            }else{
                print("Error comment did not saved!")
            }
        }
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    
    
    
    
    
   /* Showing keyboard */
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in       //fetching the posts
            if posts != nil{
                self.posts = posts!                             //store posts in the array
                self.tableView.reloadData()                     //reload the posts on tableView
            }
        }
    }
    
    /* Show how many rows are in a section. Number of rows = number of comments plus the post and the "add comment" bar */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
        
        
    }
    
    /* Create a section to print both the posts and comments. Each section has a number of row. Two dimentional array */
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //number of section
    }
    
    /* view post, caption and comment on the screen */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
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
        }else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username

            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
    }
     /* adding comments to a post*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
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
