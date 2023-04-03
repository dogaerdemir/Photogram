import Foundation

class UserSingleton
{
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var username = ""
    var userProfilePictureUrl = ""
    
    private init()
    {
        
    }
}
