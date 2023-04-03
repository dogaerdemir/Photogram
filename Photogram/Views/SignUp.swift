//
//  SignUp.swift
//  Photogram
//
//  Created by Doğa Erdemir on 31.03.2023.
//

import UIKit
import Firebase

class SignUp: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var ppImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        
        let storageReference = Storage.storage().reference()
        let mediaFolder = storageReference.child("pps") // görseller nereye konacak
        
        if emailText.text != "" && passwordText.text != "" && usernameText.text != "" {
            if let data = ppImageView.image?.jpegData(compressionQuality: 0.5) {
                Auth.auth().createUser(withEmail: self.emailText.text!, password: self.passwordText.text!) { auth, error in
                    if error != nil {
                        self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                    } else {
                        
                        let fireStore = Firestore.firestore()
                        let uuid = UUID().uuidString
                        let imageReference = mediaFolder.child("\(uuid).jpg")
                        
                        imageReference.putData(data, metadata: nil) { metadata, error in
                            if error != nil { self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error") }
                            
                            else {
                                imageReference.downloadURL { url, error in
                                    
                                    if error == nil {
                                        
                                        let imageUrl = url?.absoluteString
                                        
                                        let userDictionary = ["email": self.emailText.text!, "username":self.usernameText.text!, "userProfilePictureUrl":imageUrl!] as [String:Any]
                                        
                                        fireStore.collection("UserInfo").addDocument(data: userDictionary) { error in
                                            
                                        }
                                        
                                        self.performSegue(withIdentifier: "toFeedVC2", sender: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            makeAlert(title: "Error", message: "Username/Password/Email ?")
        }
    }
    
    @IBAction func setProfilePictureClicked(_ sender: Any) {
        let alert = UIAlertController(title: "From", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { UIAlertAction in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            vc.cameraCaptureMode = .photo
            vc.allowsEditing = true
            vc.showsCameraControls = true
            
            self.present(vc, animated: true)
        }
        
        let gallery = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) { UIAlertAction in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }

        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Galeriye picker ile gittikten sonra galeride foto seçme ve galeriyi kapatıp app'e geri dönme
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ppImageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
