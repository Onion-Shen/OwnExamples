import UIKit

public let CodeFinishNotification : String = "CodeFinishNotification"

class LockView: UIView
{
    open func refreshLockView()
    {
        _ = self.selectedBall!.map{$0.isHidden = true}//中心圆
        _ = self.ballList!.map{$0.layer.borderColor = UIColor.blue.cgColor}//外层圆
        self.dataList?.removeAll()//连线
        self.setNeedsDisplay()
    }
    
    open var codeStatus : String?
    open var isDone : Bool = false
    open var isClean : Bool = false
    
    fileprivate var ballList : Array<UIView>?
    fileprivate var selectedBall : Array<UIView>?
    fileprivate var dataList : Array<CGPoint>?
    
    fileprivate func distanceToCenter(_ point : CGPoint,center : CGPoint) -> CGFloat
    {
        let x = point.x-center.x
        let y = point.y-center.y
        return sqrt(x * x + y * y)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.ballList = Array()
        self.selectedBall = Array()
        self.dataList = Array()
        
        for i in 0..<3
        {
            for j in 0..<3
            {
                let width = 0.27*frame.size.width
                
                let offSetX = (frame.size.width-width*3)/4
                let x = offSetX+CGFloat(j)*(width+offSetX)
                
                let offSetY = (frame.size.height-width*3)/4
                let y = offSetY+CGFloat(i)*(width+offSetY)
                
                let ball = UIView(frame: CGRect(x: x, y: y, width: width, height: width))
                ball.backgroundColor = UIColor.white
                ball.layer.cornerRadius = width/2
                ball.layer.masksToBounds = true
                ball.layer.borderWidth = 2
                ball.layer.borderColor = UIColor.blue.cgColor
                self.addSubview(ball)
                self.ballList?.append(ball)
                
                let centerBall = UIView(frame: CGRect(x: ball.center.x-7.5, y: ball.center.y-7.5, width: 15.0, height: 15.0))
                centerBall.isHidden = true
                centerBall.backgroundColor = UIColor.red
                centerBall.layer.masksToBounds = true
                centerBall.layer.cornerRadius = 15.0/2;
                centerBall.layer.borderWidth = 1.0
                centerBall.layer.borderColor = UIColor.red.cgColor
                self.addSubview(centerBall)
                self.selectedBall?.append(centerBall)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first?.location(in: self)
        
        for (idx,ball) in (self.ballList?.enumerated())!
        {
            let distance = self.distanceToCenter(point!, center: ball.center)
            if distance < ball.frame.size.height/2
            {
                ball.layer.borderColor = UIColor.red.cgColor
                let centerBall = self.selectedBall?[idx]
                if self.dataList?.index(where: { return $0 == centerBall?.center }) == nil
                {
                    self.dataList?.append((centerBall?.center)!)
                    centerBall?.isHidden = false
                }
            }
        }
        
        self.handleCode()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(9.0)
        context?.setLineCap(CGLineCap.round)
        context?.setStrokeColor(UIColor.purple.cgColor)
        context?.beginPath()
        
        for point in self.dataList!
        {
            point == self.dataList!.first ?context?.move(to: point):context?.addLine(to: point)
        }
        
        context?.strokePath()
    }
    
    fileprivate func handleCode()
    {
        var string = String()
        for (idx,obj) in (self.selectedBall?.enumerated())!
        {
            if obj.isHidden == false
            {
                string += String(idx)
            }
        }
        
        if self.codeStatus == "clean"
        {
            self.isClean = true
        }
        else if self.codeStatus == "check"
        {
            self.isDone = true
        }
        else
        {
            UserDefaults.standard.set(string, forKey: LockCodeKey)
            UserDefaults.standard.synchronize()
        }
        NotificationCenter.default.post(name: Notification.Name(CodeFinishNotification), object: string)
    }
}
