import UIKit
import Firebase

class SignInVC: UIViewController
{
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpClicked(_ sender: Any)
    {
        if usernameText.text != "" && passwordText.text != "" && usernameText.text != ""
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
                    
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
        else
        {
            self.makeAlert(title: "Error", message: "Username/Password/Email ?")
        }
    }
    
    @IBAction func signInClicked(_ sender: Any)
    {
        if usernameText.text != "" && passwordText.text != "" && usernameText.text != ""
        {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { result, error in
                if error != nil{
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }
                else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }
    }
    
    func makeAlert(title:String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

