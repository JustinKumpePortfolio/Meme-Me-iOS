//
//  ViewController.swift
//  Meme Me
//
//  Created by Justin Kumpe on 6/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    
//    MARK: UIButtons
    @IBOutlet weak var buttonCamera: UIBarButtonItem!
    @IBOutlet weak var buttonAlbum: UIBarButtonItem!
    @IBOutlet weak var buttonSend: UIBarButtonItem!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    
//    MARK: UITextFields
    @IBOutlet weak var fieldTop: UITextField!
    @IBOutlet weak var fieldBottom: UITextField!
    
//    MARK: Toolbars
    @IBOutlet weak var toolbarTop: UIToolbar!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    
    
//    MARK: Text Classes
    let MemeTextFieldDelegate = MemeTextDelegate()
    
//    MARK: Image View
    @IBOutlet weak var imagePickerView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fieldTop.delegate = MemeTextFieldDelegate
        self.fieldBottom.delegate = MemeTextFieldDelegate
        self.fieldTop.defaultTextAttributes = MemeTextFieldDelegate.memeTextAttributes
        self.fieldBottom.defaultTextAttributes = MemeTextFieldDelegate.memeTextAttributes
        self.fieldTop.textAlignment = .center
        self.fieldBottom.textAlignment = .center
        self.initView(clearValues: true, hideToolbars: false)
        initButtons(enableShare: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

//    MARK: Pressed Album Button
    @IBAction func pressedPickImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
//    MARK: Pressed Camera Button
    @IBAction func pressedTakeImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
//    MARK: Cancel Pick
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    MARK: Pressed Send Button
    @IBAction func pressedSend(_ sender: Any) {
        self.share()
    }
    
//    MARK: Pressed Cancel Button
    @IBAction func pressedCancel(_ sender: Any) {
        self.initView(clearValues: true, hideToolbars: false)
    }
    
    
//    MARK: Use Picked Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            initButtons(enableShare: true)
        }
        
    }
    
//    MARK: Subscribe to Keyboard Notifications
//    Nofifies when keyboard appears/disappears
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

//    MARK: Unsubscribe from Keyboard Notifications
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    MARK: Keyboard Will Show
//    Gets called when keyboard is coming onto the screen
    @objc func keyboardWillShow(_ notification:Notification) {
        
//        Move Screen Up only if editing bottom text field
        if fieldBottom.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
//    MARK: Keyboard Will Hide
//    Gets called when keyboard is disappearing from the screen
    @objc func keyboardWillHide(_ notification:Notification) {

        view.frame.origin.y = 0
    }

//    MARK: Get Keyboard Height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
//    MARK: Meme Struct
    struct Meme{
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
//    MARK: Generate Memed Image
    func generateMemedImage() -> UIImage {

        // Hide toolbar and navbar
        self.initView(clearValues: false, hideToolbars: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Show toolbar and navbar
        self.initView(clearValues: false, hideToolbars: false)

        return memedImage
    }
    
//    MARK: Save Memed Image
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: fieldTop.text!, bottomText: fieldBottom.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        print(meme)
        initView(clearValues: true, hideToolbars: false)
    }
    
//    MARK: Share Meme
    func share(){
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> () in
            if (completed) {
                self.save(memedImage: image)
                
            }
        }
        present(controller,animated: true, completion: nil)
    }
    
//    MARK: Initialize View
    func initView(clearValues: Bool, hideToolbars: Bool){
        if clearValues{
            self.fieldTop.text = "TOP"
            self.fieldBottom.text = "BOTTOM"
            self.imagePickerView.image  = nil
            initButtons(enableShare: false)
        }
        self.toolbarBottom.isHidden = hideToolbars
        self.toolbarTop.isHidden = hideToolbars
    }
    
//    MARK: Initialize Buttons
    func initButtons(enableShare: Bool){
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        buttonSend.isEnabled = enableShare
    }
}

