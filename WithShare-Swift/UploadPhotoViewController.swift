//
//  UploadPhotoViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/23/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class UploadPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var profileImage: UIImageView!
    
//    var imagePicker: UIImagePickerController!
    
    var user: User?
    var photoDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.profilePhoto: ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Pick Image
    
    @IBAction func choosePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
        
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func takePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
        
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        user?.profilePhoto = profileImage.image
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Actions
    @IBAction func uploadPhoto(sender: AnyObject) {
        if (user?.profilePhoto != nil) {
            // down scale photo
            user?.profilePhoto = resizeImage((user?.profilePhoto!)!, newWidth: 200)
            // Base64 encode photo
            let imageData:NSData = UIImagePNGRepresentation((user?.profilePhoto)!)!
            let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)

            photoDict[Constants.ServerModelField_User.username] = user?.username
            photoDict[Constants.ServerModelField_User.profilePhoto] = strBase64
            
            ApiManager.sharedInstance.editProfile(user!, profileData: photoDict, onSuccess: {(user) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("upload photo success!")
                    self.performSegueWithIdentifier("toHomePageSegue", sender: self)
                }
                }, onError: {(error) in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        print("create profile error!")
                        let alert = UIAlertController(title: "Unable to create profile!", message:
                            "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            })
        }
        else {
            self.performSegueWithIdentifier("toHomePageSegue", sender: self)
        }
    }
    
    @IBAction func skipPhoto(sender: AnyObject) {
        self.performSegueWithIdentifier("toHomePageSegue", sender: self)
    }
    
    // MARK: resize image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
