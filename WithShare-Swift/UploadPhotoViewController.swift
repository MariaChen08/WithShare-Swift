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
    
    @IBAction func choosePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
        
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func takePhoto(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
        
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        user?.profilePhoto = profileImage.image
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        self.dismiss(animated: true, completion: nil)
    }
    
    // Actions
    @IBAction func uploadPhoto(_ sender: AnyObject) {
        if (user?.profilePhoto != nil) {
            // down scale photo
            user?.profilePhoto = resizeImage((user?.profilePhoto!)!, newWidth: 200)
            // Base64 encode photo
            let imageData:Data = UIImagePNGRepresentation((user?.profilePhoto)!)!
            let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)

            photoDict[Constants.ServerModelField_User.username] = user?.username
            photoDict[Constants.ServerModelField_User.profilePhoto] = strBase64
            
            ApiManager.sharedInstance.editProfile(user!, profileData: photoDict as Dictionary<String, AnyObject>, onSuccess: {(user) in
                OperationQueue.main.addOperation {
                    print("upload photo success!")
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.performSegue(withIdentifier: "toHomePageSegue", sender: self)
                }
                }, onError: {(error) in
                    OperationQueue.main.addOperation {
                        print("create profile error!")
                        let alert = UIAlertController(title: "Unable to create profile!", message:
                            "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
            })
        }
        else {
            self.performSegue(withIdentifier: "toHomePageSegue", sender: self)
        }
    }
    
    @IBAction func skipPhoto(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toHomePageSegue", sender: self)
    }
    
    // MARK: resize image
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
