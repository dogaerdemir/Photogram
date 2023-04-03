import UIKit
import Firebase

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var feedUsernameLabel: UILabel!
    @IBOutlet weak var cellComment: UILabel!
    @IBOutlet weak var multipleImageIndicator: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    @IBOutlet weak var postProfilePicture: UIImageView!
    
    @IBOutlet weak var likeButtonWithText: UIButton!
    
    var isLikeable : Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func likeButtonWithTextClicked(_ sender: Any) {
        // İŞE YARAMAZ KOD, DENEME AMAÇLI
        if isLikeable == true {
            Firestore.firestore().collection("Posts").document(documentIdLabel.text!).updateData(["likes":FieldValue.increment(Int64(1))])
            isLikeable = false
            likeButtonWithText.setTitle("Dislike", for: .normal)
            likeButtonWithText.setTitleColor(UIColor.red, for: .normal)
        } else if isLikeable == false {
            Firestore.firestore().collection("Posts").document(documentIdLabel.text!).updateData(["likes":FieldValue.increment(Int64(-1))])
            isLikeable = true
            likeButtonWithText.setTitle("Like", for: .normal)
            likeButtonWithText.setTitleColor(UIColor.systemBlue, for: .normal)
        }
    }
    
    @IBAction func ellipsisButton(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let share = UIAlertAction(title: "Share", style: UIAlertAction.Style.default) { UIAlertAction in
            if let image = (self.feedImageView.image) {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                self.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }
        
        let delete = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { UIAlertAction in
            Firestore.firestore().collection("Snaps").document(self.documentIdLabel.text!).delete()
        }
        
        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(share)
        alert.addAction(delete)
        alert.addAction(dismiss)
        
        self.window?.rootViewController?.present(alert, animated: true)
    }
}
