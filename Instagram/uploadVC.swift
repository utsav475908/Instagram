//
//  uploadVC.swift
//  Instagram
//
//  Created by Bobby Negoat on 11/27/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Parse

class uploadVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var titleTxt: UITextView!
    
    @IBOutlet weak var publishBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init publichBtn
        initPublishBtn()
        
        // hide kyeboard tap
        tapToHideKyeboard()
        
         // select image tap
        tapToSelectImg()
        
        //set text view layer
        setTextViewLayer()
        
        // add done button above keyboard
         addDoneButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  // clicked publish button
    @IBAction func publishBtn_clicked(_ sender: Any) {
        
        // dissmiss keyboard
        self.view.endEditing(true)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
      
// send pic to server after converting to FILE and comprassion
  let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        
// send #hashtag to server
        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
    // finally save information
 object.saveInBackground (block: { (success, error)  in
    if error == nil {
                
        // send notification wiht name "uploaded"
    NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
    // switch to another ViewController at 0 index of tabbar
    self.tabBarController!.selectedIndex = 1
                
        // reset everything
    self.viewDidLoad()
self.titleTxt.text = ""
            }
        })
    }
}// uploadVC class over line

// custom functions
extension uploadVC{
    
    // set text view layer
  fileprivate func setTextViewLayer(){
    
  self.titleTxt.layer.borderColor = UIColor.black.cgColor
  self.titleTxt.layer.cornerRadius = 0
  self.titleTxt.layer.borderWidth = 1
  self.titleTxt.backgroundColor = UIColor.white
    }

   // init publichBtn
fileprivate func initPublishBtn(){
    self.publishBtn.isEnabled = false
    self.publishBtn.backgroundColor = UIColor.purple
}
    
    // hide kyeboard tap
fileprivate func tapToHideKyeboard(){
    let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
    hideTap.numberOfTapsRequired = 1
    self.view.isUserInteractionEnabled = true
    self.view.addGestureRecognizer(hideTap)
}
   
     // select image tap
    fileprivate func tapToSelectImg(){
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
    }
    
    // hide kyeboard function
@objc fileprivate func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    // func to call pickerViewController
 @objc fileprivate func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // zooming in / out function
  @objc fileprivate func zoomImg() {
    
    // define frame of zoomed image
    let zoomed = CGRect(x: 0, y: self.view.center.y - UIScreen.main.bounds.size.width / 2, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
    
    // frame of unzoomed (small) image
    let unzoomed = CGRect(x: 16, y: 130, width: 82, height: 82)
    
    // if picture is unzoomed, zoom it
    if picImg.frame == unzoomed {
    
        UIView.animate(withDuration: 0.3, animations: {
            // resize image frame
            self.picImg.frame = zoomed
            
            // hide objects from background
            self.view.backgroundColor = .black
            self.titleTxt.alpha = 0
            self.publishBtn.alpha = 0
        })
        
    }else{
        
        UIView.animate(withDuration: 0.3, animations: {
            // resize image frame
            self.picImg.frame = unzoomed
            
            // unhide objects from background
            self.view.backgroundColor = .white
            self.titleTxt.alpha = 1
            self.publishBtn.alpha = 1
        })
    }
 
    }
    
    // add done button above keyboard
    fileprivate func addDoneButton(){
        
         let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboardTap))
        
        toolBar.setItems([flexibleSpace,doneButton], animated: true)
        
        self.titleTxt.inputAccessoryView = toolBar
    }
}

//image picker --delegate
extension uploadVC{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
    // enable publish btn
       publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
    // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
}











