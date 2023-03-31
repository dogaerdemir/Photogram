import UIKit
import Firebase
import SDWebImage
import ImageSlideshow

class Feed: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    var documentIdArray = [String]()
    var likeArray = [Int]()
    var snapArray = [Snap]()
    var chosenSnap : Snap?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        getSnapsFromFirebase()
        getUserInformation()
    }
    
    @objc func refresh(refresh: UIRefreshControl)
    {
        getSnapsFromFirebase()
        getUserInformation()
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func getSnapsFromFirebase()
    {
        fireStoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            self.snapArray.removeAll(keepingCapacity: false)
            self.likeArray.removeAll(keepingCapacity: false)
            self.documentIdArray.removeAll(keepingCapacity: false)
            
            self.tableView.reloadData()
            if error != nil
            {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }
            else
            {
                if snapshot?.isEmpty == false && snapshot != nil
                {
                    for document in snapshot!.documents
                    {
                        let documentId = document.documentID
                        self.documentIdArray.append(documentId)
                        
                        if let likes = document.get("likes") as? Int
                        {
                            self.likeArray.append(likes)
                            
                            if let comment = document.get("comment") as? String
                            {
                                if let username = document.get("postOwner") as? String
                                {
                                    if let imageUrlArray = document.get("imageUrlArray") as? [String]
                                    {
                                        if let date = document.get("date") as? Timestamp
                                        {
                                            // Güncel zamandan (Date()) kaydedilen snap zamanını (date.dateValue()) çıkar ve saat olarak farkını bul
                                            if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour
                                            {
                                                if difference >= 24
                                                {
                                                    self.fireStoreDatabase.collection("Posts").document(documentId).delete
                                                    { error in
                                                        if error != nil
                                                        {
                                                            self.makeAlert(title: "Error", message: error!.localizedDescription)
                                                        }
                                                    }
                                                }
                                                
                                                else
                                                {
                                                    let snap = Snap(username: username, imageUrlAray: imageUrlArray, date: date.dateValue(), timeDifference: 24 - difference, comment: comment, likes: likes)
                                                    self.snapArray.append(snap)
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                else
                {
                    
                }
            }
        }
    }

    func getUserInformation()
    {
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
            if error != nil
            {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }
            
            else
            {
                if snapshot?.isEmpty == false && snapshot != nil
                {
                    for document in snapshot!.documents
                    {
                        if let username = document.get("username") as? String
                        {
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = username
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
    
        cell.feedUsernameLabel.text = snapArray[indexPath.row].username
        cell.feedImageCiew.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlAray[0]))
        cell.cellComment.text = snapArray[indexPath.row].comment
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        
        if (self.snapArray[indexPath.row].imageUrlAray.count > 1)
        {
            cell.multipleImageIndicator.isHidden = false
        }
        else{
            cell.multipleImageIndicator.isHidden = true
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toSnapVC"
        {
            let destinationVC = segue.destination as! PostDetail
            destinationVC.selectedSnap = chosenSnap
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        chosenSnap = self.snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
}
