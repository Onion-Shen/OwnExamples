import UIKit

class CalendarItem : UIView
{
    var year : Int = 0
    var month : Int = 0
    var day : Int = 0
    var contentLabel : UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.25
        
        self.contentLabel.textAlignment = .center
        self.addSubview(self.contentLabel)
    }
    
    override func layoutSubviews() 
    {
        super.layoutSubviews()
        
        self.contentLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
