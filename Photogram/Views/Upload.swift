import UIKit
import Firebase

class Upload: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselsec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    // Görsel seçme fotosuna tıklanınca olacaklar -galeriye gitme-
    @objc func gorselsec() {
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
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        // Storage
        let storageReference = Storage.storage().reference()
        let mediaFolder = storageReference.child("media")// görseller nereye konacak
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }
                
                else {
                    imageReference.downloadURL { url, error in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            // Firestore
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Posts").whereField("postOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { snapshot, error in
                                if error != nil { }
                                
                                else {
                                    // Önceden fotoğrafı var, üstüne fotoğraf eklenecek
                                    if snapshot?.isEmpty == false && snapshot != nil {
                                        for document in snapshot!.documents {
                                            let documentId = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String:Any]
                                                
                                                fireStore.collection("Posts").document(documentId).setData(additionalDictionary, merge: true) { error in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.imageView.image = UIImage(named: "indir")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // İlk fotoğraf
                                    else {
                                        let snapDictionary = ["imageUrlArray":[imageUrl!], "postOwner":UserSingleton.sharedUserInfo.username, "postProfilePicture":UserSingleton.sharedUserInfo.userProfilePictureUrl,
                                                              "date":FieldValue.serverTimestamp(), "comment":self.commentText.text!, "likes":0] as! [String:Any]
                                        
                                        fireStore.collection("Posts").addDocument(data: snapDictionary) { error in
                                            if error != nil {
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            }
                                            
                                            else {
                                                self.tabBarController?.selectedIndex = 0
                                                self.imageView.image = UIImage(named: "indir")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupTextFields() {
        let toolbar = UIToolbar()
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonClicked))
        
        toolbar.setItems([space, done], animated: true)
        toolbar.sizeToFit()
        
        commentText.inputAccessoryView = toolbar
    }
        
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
}
