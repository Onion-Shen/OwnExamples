import UIKit

public let refreshCmd : String = "refreshIndicator"

class Indicator: UIView
{
    open func refresh(_ code : String)
    {
        guard code.isEmpty || self.ballList == nil else
        {
            if code == refreshCmd
            {
                _ = self.ballList!.map{ $0.backgroundColor = UIColor.white }
            }
            else
            {
                for ch in code.utf8
                {
                    let index = Int(ch - 48)
                    if index < (self.ballList?.count)!
                    {
                        self.ballList?[index].backgroundColor = UIColor.cyan
                    }
                }
            }
            return
        }
    }
    
    fileprivate var ballList : Array<UILabel>?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.ballList = Array()
        for i in 0..<3
        {
            for j in 0..<3
            {
                let width = 0.2*frame.size.width
                
                let offSetX = (frame.size.width-width*3)/4
                let x = offSetX+CGFloat(j)*(width+offSetX)
                
                let offSetY = (frame.size.height-width*3)/4
                let y = offSetY+CGFloat(i)*(width+offSetY)
                
                let ball = UILabel(frame: CGRect(x: x, y: y, width: width, height: width))
                ball.layer.cornerRadius = width/2
                ball.layer.masksToBounds = true
                ball.layer.borderWidth = 0.5
                ball.layer.borderColor = UIColor.blue.cgColor
                self.addSubview(ball)
                self.ballList?.append(ball)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
