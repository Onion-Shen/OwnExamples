import UIKit

class Slider: UIControl
{    
    var trackerImage : UIImage? = nil
    var radius : CGFloat?

    private var currentMaxValue : CGFloat = 0.0
    private var currentMinValue : CGFloat = 0.0
    
    private var leftTracker : UIImageView? = nil
    private var rightTracker : UIImageView? = nil
    
    private var bgView : UIView? = nil
    private var innerView : UIView? = nil
    
    private var leftOrigin : CGPoint = CGPoint.zero
    private var rightOrigin : CGPoint = CGPoint.zero
    
    private var leftPanLocationInSelf : CGPoint = CGPoint.zero
    private var rightPanLocationInSelf : CGPoint = CGPoint.zero
    
    private var step : CGFloat? = nil
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset()
    {
        self.currentMinValue = self.radius!
        self.currentMaxValue = frame.width - self.radius!
        self.setNeedsLayout()
    }
    
    func showSlider()
    {
        let validLength = frame.width - 2 * self.radius!
        let stepCount : CGFloat = 100
        self.step = validLength / stepCount
        
        self.currentMinValue = self.radius!
        self.currentMaxValue = frame.width - self.radius!
        
        self.createBackgroundView()
        self.createInnerView()
        self.createBothTracker()
    }
    
    private func factor(number:CGFloat) -> UInt {
        var res = number / self.step!
        if number >= (res - 0.5) * self.step! {
            res += 1
        }
        return UInt(res)
    }
    
    private func round(number:CGFloat) -> CGFloat {
        return number <= 0.0 ? 0.0 : CGFloat(self.factor(number: number)) * self.step!
    }
    
    private func createBackgroundView()
    {
        self.bgView = UIView(frame: CGRect(x: self.radius!, y: (self.frame.height - 3.0) / 2.0, width: self.frame.width - 2 * self.radius!, height: 3.0))
        self.bgView?.layer.cornerRadius = 3.0
        self.bgView?.backgroundColor = UIColor.gray
        self.addSubview(self.bgView!)
    }
    
    private func createBothTracker()
    {
        let trackerWidth = self.radius! * 2
        let trackerHeight = self.frame.height
        
        self.leftTracker = UIImageView(image: self.trackerImage!)
        self.leftTracker?.frame = CGRect(x: 0, y: 0, width: trackerWidth, height: trackerHeight)
        self.leftOrigin = (self.leftTracker?.frame.origin)!
        self.addSubview(self.leftTracker!)
        
        self.rightTracker = UIImageView(image: self.trackerImage!)
        self.rightTracker?.frame = CGRect(x: self.frame.width - trackerWidth, y: 0, width: trackerWidth, height: trackerHeight)
        self.rightOrigin = (self.rightTracker?.frame.origin)!
        self.addSubview(self.rightTracker!)
    }
    
    private func createInnerView()
    {
        self.innerView = UIView(frame: (self.bgView?.frame)!)
        self.innerView?.backgroundColor = UIColor.red
        self.addSubview(self.innerView!)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        let touchPoint = touch.location(in: self)
        
        let leftRect = self.leftTracker!.frame
        if leftRect.contains(touchPoint)
        {
            self.leftTracker!.isHighlighted = true
            self.leftPanLocationInSelf = touchPoint
        }
        
        let rightRect = self.rightTracker!.frame
        if rightRect.contains(touchPoint)
        {
            self.rightTracker!.isHighlighted = true
            self.rightPanLocationInSelf = touchPoint
        }
        
        return self.leftTracker!.isHighlighted || self.rightTracker!.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        if !(self.leftTracker!.isHighlighted || self.rightTracker!.isHighlighted)
        {
            return false
        }
        
        let touchPoint = touch.location(in: self)
        var render = false
        
        if self.leftTracker!.isHighlighted {
            let offset = touchPoint.x - self.leftPanLocationInSelf.x
            let tmpVal = self.currentMinValue + offset
            
            if offset > 0 && tmpVal + self.radius! > self.rightTracker!.frame.origin.x {
                self.currentMinValue = self.rightTracker!.frame.origin.x - self.radius!
                
                let diff = tmpVal + self.radius! - self.rightTracker!.frame.origin.x
                self.leftPanLocationInSelf = CGPoint(x: touchPoint.x - diff, y: touchPoint.y)
            } else {
                self.leftPanLocationInSelf = touchPoint
                self.currentMinValue = tmpVal
                
                if self.currentMinValue < self.radius! {
                    self.currentMinValue = self.radius!
                }
            }
            
            render = true
        }
        
        if self.rightTracker!.isHighlighted {
            let offset = touchPoint.x - self.rightPanLocationInSelf.x
            let tmpVal = self.currentMaxValue + offset
            
            if offset < 0 && tmpVal - self.radius! < self.leftTracker!.frame.maxX {
                self.currentMaxValue = self.leftTracker!.frame.maxX + self.radius!
                
                let diff = self.leftTracker!.frame.maxX - (tmpVal - self.radius!)
                self.rightPanLocationInSelf = CGPoint(x: touchPoint.x - diff, y: touchPoint.y)
            } else {
                self.rightPanLocationInSelf = touchPoint
                self.currentMaxValue = tmpVal
                
                let maxX = self.frame.size.width - self.radius!
                if self.currentMaxValue > maxX {
                    self.currentMaxValue = maxX
                }
            }
            
            render = true
        }
        
        if render
        {
            self.setNeedsLayout()
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?)
    {
        var isRedraw = false
        
        if self.leftTracker!.isHighlighted {
            let minVal = self.round(number: self.currentMinValue)
            if abs(minVal - self.currentMinValue) >= self.step! {
                self.currentMinValue = minVal
                isRedraw = true
            }
        }
        
        if self.rightTracker!.isHighlighted {
            let maxVal = self.round(number: self.currentMaxValue)
            if abs(maxVal - self.currentMaxValue) >= self.step! {
                self.currentMaxValue = maxVal
                isRedraw = true
            }
        }
        
        if isRedraw {
            self.setNeedsLayout()
        }
        
        self.leftTracker!.isHighlighted = false
        self.rightTracker!.isHighlighted = false
    }
    
    override func cancelTracking(with event: UIEvent?)
    {
        self.leftTracker!.isHighlighted = false
        self.rightTracker!.isHighlighted = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let view = super.hitTest(point, with: event)
        if view == nil
        {
            return view
        }
        
        if view!.isDescendant(of: self)
        {
            return self
        }
        
        return view
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.frameCheck(byView: self.leftTracker!, andFrame: self.leftTrackerRect())
        self.frameCheck(byView: self.rightTracker!, andFrame: self.rightTrackerRect())
        self.frameCheck(byView: self.innerView!, andFrame: self.innerViewRect())
    }
    
    private func frameCheck(byView view:UIView, andFrame frame:CGRect) {
        if view.frame != frame {
            view.frame = frame
        }
    }
    
    private func leftTrackerRect() -> CGRect
    {
        var frame = self.leftTracker?.frame
        let minX = self.radius
        if self.currentMinValue == minX
        {
            frame?.origin = self.leftOrigin
        }
        else
        {
            frame?.origin.x = self.currentMinValue - self.radius!
        }
        return frame!
    }
    
    private func rightTrackerRect() -> CGRect
    {
        var frame = self.rightTracker?.frame
        let maxX = self.frame.size.width - self.radius!
        if self.currentMaxValue == maxX
        {
            frame?.origin = self.rightOrigin
        }
        else
        {
            frame?.origin.x = self.currentMaxValue - self.radius!
        }
        return frame!
    }
    
    private func innerViewRect() -> CGRect
    {
        var frame = self.innerView!.frame
        frame.origin.x = self.leftTracker!.center.x
        frame.size.width = self.rightTracker!.center.x - frame.origin.x
        return frame
    }
}
