//
//  MemeEditorViewController.swift
//  Meme Me
//
//  Created by Justin Kumpe on 6/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
    
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
        initTextFields(fieldTop)
        initTextFields(fieldBottom)
        initView(clearValues: true, hideToolbars: false)
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
        showImagePicker(.photoLibrary)
    }
    
//    MARK: Pressed Camera Button
    @IBAction func pressedTakeImage(_ sender: Any) {
        showImagePicker(.camera)
    }
    
//    MARK: Show Image Picker
//    Loads image picker using supplied source type
    func showImagePicker(_ source: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
//    MARK: Cancel Pick
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    MARK: Pressed Send Button
    @IBAction func pressedSend(_ sender: Any) {
        share()
    }
    
//    MARK: Pressed Cancel Button
    @IBAction func pressedCancel(_ sender: Any) {
        initView(clearValues: true, hideToolbars: false)
        dismiss(animated: true, completion: nil)
    }
    
    
//    MARK: Use Picked Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            initButtons(enableShare: true)
            resizeImageView()
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
    
    
//    MARK: Generate Memed Image
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        initView(clearValues: false, hideToolbars: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.bounds.size)
        view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Show toolbar and navbar
        initView(clearValues: false, hideToolbars: false)

        return memedImage
    }
    
//    MARK: Save Memed Image
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: fieldTop.text!, bottomText: fieldBottom.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        initView(clearValues: true, hideToolbars: false)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
//    MARK: Share Meme
    func share(){
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> () in
            if completed {
                self.save(memedImage: image)
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        present(controller,animated: true, completion: nil)
    }
    
//    MARK: Initialize View
    func initView(clearValues: Bool, hideToolbars: Bool){
        if clearValues{
            fieldTop.text = "TOP"
            fieldBottom.text = "BOTTOM"
            imagePickerView.image  = nil
            initButtons(enableShare: false)
        }
        toolbarBottom.isHidden = hideToolbars
        toolbarTop.isHidden = hideToolbars
    }
    
//    MARK: Initialize Buttons
    func initButtons(enableShare: Bool){
        buttonCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        buttonSend.isEnabled = enableShare
    }
    
/*    MARK: viewWillTransition
      Resizes image view when transitioning to/from Landscape/Portrait
 */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in

            self.resizeImageView()
        })
    }
    
/*    MARK: Resize Image View
    Resizes image view to place text fields on image.
 */
    func resizeImageView(){
        if let image = imagePickerView.image{
        
            let ratio = image.size.width / image.size.height
            var newWidth = view.frame.width
            var newHeight = view.frame.width / ratio
            if UIDevice.current.orientation.isLandscape{
                newWidth = view.frame.height / ratio
                newHeight = view.frame.height
            }
            let constraints = [
                imagePickerView.heightAnchor.constraint(equalToConstant: newHeight),
                imagePickerView.widthAnchor.constraint(equalToConstant: newWidth)
            ]
            NSLayoutConstraint.activate(constraints)
            view.layoutIfNeeded()
            imagePickerView.contentMode = .scaleAspectFit
        }
    }
    
    func initTextFields(_ textField: UITextField){
        textField.delegate = MemeTextFieldDelegate
        textField.defaultTextAttributes = MemeTextFieldDelegate.memeTextAttributes
        textField.textAlignment = .center
    }
    
}

