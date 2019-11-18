//
//  CameraViewController.swift
//  Parstagram
//
//  Created by KimlyT. on 11/17/19.
//  Copyright © 2019 KimlyT. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
 {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts")       //create new row on Heroku with the properties below
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()   //save the resized image as png
        let file = PFFileObject(data: imageData!)    //imageData is saved at seperate table
        
        post["image"] = file                         //have a url to the image
        
        post.saveInBackground { (success, error) in
            if success{
                print("save!")
            }else{
                print("error!")
            }
        }
        
        
    }
    
    @IBAction func onTapCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self       //when done taking photo call the delegate to let it knows what user took
        picker.allowsEditing = true  //allow the user to edit the photo
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {       
        
        let image = info[.editedImage] as! UIImage       //store the mage as an array
        
        let size = CGSize(width: 300, height: 300)      //resized the image to 300 times 300
        let scaleImage = image.af_imageScaled(to: size) // use AlamofireImage instead of Parse/Heroku
        
        imageView.image = scaleImage
        
        dismiss(animated: true, completion: nil)      //dismiss the camera
        
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
