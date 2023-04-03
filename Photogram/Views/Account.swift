import UIKit
import Firebase

class Account: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = "Email: \(Auth.auth().currentUser!.email!)"
        
        Firestore.firestore().collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
            if error == nil {
                if snapshot?.isEmpty == false && snapshot != nil {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            self.usernameLabel.text = "Username: \(username)"
                        }
                    }
                }
            }
        }
        
        
        /*  FETCHING SPECIFIC FIELD VALUE FROM A SPECIFIC DOCUMENT
        firestoreDatabase.collection("Snaps").document(documentIdLabel.text!).getDocument { document, error in
            if let document = document
            {
                let likes = document.get("likes") as! Int
                self.likeLabel.text! = String(likes)
            }else {
                print("Document does not exist in cache")
            }
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailLabel.text = "Email: \(Auth.auth().currentUser!.email!)"
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toSignInVC", sender: nil)
        } catch{}
    }
}
