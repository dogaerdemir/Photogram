import UIKit
import ImageSlideshow

class PostDetail: UIViewController
{
    var selectedSnap : Snap?
    var inputArray = [SDWebImageSource]()
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let snap = selectedSnap
        {
            timeLabel.text = "Hours Left: \(snap.timeDifference)"
            for imageUrl in snap.imageUrlAray
            {
                inputArray.append(SDWebImageSource(urlString: imageUrl)!)
            }
        }
        
        let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.9))
        
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.black
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        
        imageSlideShow.pageIndicator = pageIndicator
        imageSlideShow.backgroundColor = UIColor.white
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        imageSlideShow.setImageInputs(inputArray)
        self.view.addSubview(imageSlideShow)
        self.view.bringSubviewToFront(timeLabel)
        
        // Do any additional setup after loading the view.
    }
}
