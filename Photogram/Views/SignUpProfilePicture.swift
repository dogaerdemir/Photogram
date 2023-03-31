//
//  SignUpProfilePicture.swift
//  Photogram
//
//  Created by Doğa Erdemir on 31.03.2023.
//

import UIKit

class SignUpProfilePicture: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ppImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setProfilePictureClicked(_ sender: Any) {
        
            let alert = UIAlertController(title: "From", message: "", preferredStyle: UIAlertController.Style.actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default){ UIAlertAction in
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.sourceType = .camera
                vc.cameraCaptureMode = .photo
                vc.allowsEditing = true
                vc.showsCameraControls = true
                
                self.present(vc, animated: true)
            }
            
            let gallery = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default){ UIAlertAction in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }

            let dismiss = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel){ UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(camera)
            alert.addAction(gallery)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func completeClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toFeedVC2", sender: nil)
    }
    
    // Galeriye picker ile gittikten sonra galeride foto seçme ve galeriyi kapatıp app'e geri dönme
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        ppImageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
