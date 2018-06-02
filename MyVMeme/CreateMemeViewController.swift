//
//  ViewController.swift
//  MyVMeme
//
//  Created by Vedarth Solutions on 4/18/18.
//  Copyright © 2018 Vedarth Solutions. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    //outlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black /* TODO: fill in appropriate UIColor */,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white/* TODO: fill in appropriate UIColor */,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.5/* TODO: fill in appropriate Float */]
    
    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        setupDefaults()
    }
    @IBAction func pickFromGallery(_ sender: Any) {
        presentAnImageWithSourceType(sourceType: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func pickFromCamera(_ sender: Any) {
        presentAnImageWithSourceType(sourceType: UIImagePickerControllerSourceType.camera)
    }
    
    private func presentAnImageWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate=self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupDefaults() -> Void {
        imageView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled=false
        topText.isHidden = true
        bottomText.isHidden = true
        configureTextFields(textField: topText, content: defaultTopText)
        configureTextFields(textField: bottomText, content: defaultBottomText)
    }
    
    private func configureTextFields(textField: UITextField, content: String) -> Void {
        textField.text = content
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
    }
    
    private func clearTextField(textField: UITextField) -> Void {
        textField.clearsOnBeginEditing=true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    @objc func keyboardWillShow_(_ notification:Notification) {
        if (bottomText.isEditing) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide_(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearTextField(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                self.save(memedImage: memedImage)
            }
        }
        
        if let popoverPresentationController = activityController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
        }
        present(activityController, animated: true, completion: nil)
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topText.text!,
                        bottomText: bottomText.text!,
                        originalImage: imageView.image!,
                        memedImage: memedImage)
        print(meme.description)
    }
    
    private func generateMemedImage() -> UIImage {
        // Render view to an image
        // hide  toolbar and navbar
        navigationController?.setNavigationBarHidden(true, animated: false)
        topNavigationBar.isHidden = true
        bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: false)
        topNavigationBar.isHidden = false
        bottomToolbar.isHidden = false
        return memedImage
    }
}

extension CreateMemeViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: {[weak self] in
            guard let fieldSetters = self else {
                return
            }
            fieldSetters.shareButton.isEnabled = true
            fieldSetters.cancelButton.isEnabled = true
            fieldSetters.topText.isHidden = false
            fieldSetters.bottomText.isHidden = false
        })
    }
}



