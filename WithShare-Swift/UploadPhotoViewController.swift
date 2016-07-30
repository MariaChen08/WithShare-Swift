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
    
    var imagePicker: UIImagePickerController!
    
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imagePicker.delegate = self
    }
    
    //MARK: Actions
    
    @IBAction func choosePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}
