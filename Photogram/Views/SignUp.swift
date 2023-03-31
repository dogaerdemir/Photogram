//
//  SignUp.swift
//  Photogram
//
//  Created by Doğa Erdemir on 31.03.2023.
//

import UIKit
import Firebase

class SignUp: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" && usernameText.text != ""
        {
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!){ auth, error in
                if error != nil
                {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }
                else
                {
                    let fireStore = Firestore.firestore()
                    let userDictionary = ["email": self.emailText.text!, "username":self.usernameText.text!] as [String:Any]
                    
                    fireStore.collection("UserInfo").addDocument(data: userDictionary) { error in
                        
                    }
                    
                    self.performSegue(withIdentifier: "toPpVC", sender: nil)
                }
            }
        }
        else
        {
            makeAlert(title: "Error", message: "Username/Password/Email ?")
        }
    }
    
}
