import UIKit

extension UIView
{
    func screenShot(rect:CGRect?) -> UIImage?
    {
        var image:UIImage? = nil
        if rect == nil
        {
            UIGraphicsBeginImageContext(self.frame.size)
            let ctx = UIGraphicsGetCurrentContext()
            self.layer.render(in: ctx!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        else
        {
            UIGraphicsBeginImageContext(self.frame.size)
            let ctx = UIGraphicsGetCurrentContext()
            ctx!.saveGState()
            UIRectClip(rect!)
            self.layer.render(in: ctx!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
}
