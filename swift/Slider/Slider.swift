import UIKit

class Slider: UIControl {
    
    var max : CGFloat = 0.0
    var trackImageName : String? = nil

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
    
    private var radius : CGFloat = 14.0
    
    private var step : CGFloat? = nil
    private var stepCount : NSInteger = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white

        let validLength = frame.width - 2 * self.radius
        self.step = validLength / CGFloat(self.stepCount)

        self.currentMinValue = self.radius
        self.currentMaxValue = frame.width - self.radius
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func minValueAtParameterScale() -> CGFloat? {
        if abs(self.radius - self.currentMinValue) <= 0.5 {
            return nil
        }
        let x = CGFloat(self.factor(number: self.currentMinValue)) * (self.max / CGFloat(self.stepCount))
        return x
    }
    
    func maxValueAtParameterScale() -> CGFloat? {
        if abs(self.frame.size.width - self.radius - self.currentMaxValue) <= 0.5 {
            return nil
        }
        let x = CGFloat(self.factor(number: self.currentMaxValue)) * (self.max / CGFloat(self.stepCount))
        return x
    }
    
    func reset() {
        self.currentMinValue = self.radius
        self.currentMaxValue = self.frame.size.width - self.radius
        self.setNeedsLayout()
    }
    
    func factor(number:CGFloat) -> UInt {
        var res = number / self.step!
        if number >= (res - 0.5) * self.step! {
            res += 1
        }
        return UInt(res)
    }
    
    func round(number:CGFloat) -> CGFloat {
        return number <= 0.0 ? 0.0 : CGFloat(self.factor(number: number)) * self.step!
    }
    
    func createSubViews() {
        self.createBackgroundView()
        self.createBothTracker()
        self.createInnerView()
    }
    
    func createBackgroundView() {
        self.bgView = UIView(frame: CGRect(x: 0, y: 20 - 1.5, width: self.frame.size.width, height: 3.0))
        self.bgView?.layer.cornerRadius = 3.0
        self.bgView?.backgroundColor = UIColor.gray
        self.addSubview(self.bgView!)
    }
    
    func createBothTracker() {
        let trackerImage = UIImage(named: self.trackImageName!)

        self.leftTracker = UIImageView(image: trackerImage)
        self.leftTracker?.frame = CGRect(x: 0, y: 0, width: 28.0, height: 40.0)
        self.leftTracker?.center = CGPoint(x: 14.0, y: 20.0)
        self.leftOrigin = (self.leftTracker?.frame.origin)!
        self.addSubview(self.leftTracker!)
        
        self.rightTracker = UIImageView(image: trackerImage)
        self.rightTracker?.frame = CGRect(x: 0, y: 0, width: 28.0, height: 40.0)
        self.rightTracker?.center = CGPoint(x: self.frame.size.width - 14.0, y: 20.0)
        self.rightOrigin = (self.rightTracker?.frame.origin)!
        self.addSubview(self.rightTracker!)
    }
    
    func createInnerView() {
        var frame = (self.bgView?.frame)!
        frame.origin.x = (self.leftTracker?.center.x)!
        frame.size.width = (self.rightTracker?.center.x)! - frame.origin.x
        
        self.innerView = UIView(frame: frame)
        self.innerView?.backgroundColor = UIColor.red
        self.addSubview(self.innerView!)
        
        self.insertSubview(self.innerView!, belowSubview: self.leftTracker!)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        
        let leftRect = self.leftTracker!.frame
        if leftRect.contains(touchPoint) {
            self.leftTracker!.isHighlighted = true
            self.leftPanLocationInSelf = touchPoint
        }
        
        let rightRect = self.rightTracker!.frame
        if rightRect.contains(touchPoint) {
            self.rightTracker!.isHighlighted = true
            self.rightPanLocationInSelf = touchPoint
        }
        
        return self.leftTracker!.isHighlighted || self.rightTracker!.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        
        if self.leftTracker!.isHighlighted {
            let offset = touchPoint.x - self.leftPanLocationInSelf.x
            let tmpVal = self.currentMinValue + offset
            
            if offset > 0 && tmpVal + self.radius > self.rightTracker!.frame.origin.x {
                self.currentMinValue = self.rightTracker!.frame.origin.x - self.radius
                
                let diff = tmpVal + self.radius - self.rightTracker!.frame.origin.x
                self.leftPanLocationInSelf = CGPoint(x: touchPoint.x - diff, y: touchPoint.y)
            } else {
                self.leftPanLocationInSelf = touchPoint
                self.currentMinValue = tmpVal
                
                if self.currentMinValue < self.radius {
                    self.currentMinValue = self.radius
                }
            }
            
            self.setNeedsLayout()
        }
        
        if self.rightTracker!.isHighlighted {
            let offset = touchPoint.x - self.rightPanLocationInSelf.x
            let tmpVal = self.currentMaxValue + offset
            
            if offset < 0 && tmpVal - self.radius < self.leftTracker!.frame.maxX {
                self.currentMaxValue = self.leftTracker!.frame.maxX + self.radius
                
                let diff = self.leftTracker!.frame.maxX - (tmpVal - self.radius)
                self.rightPanLocationInSelf = CGPoint(x: touchPoint.x - diff, y: touchPoint.y)
            } else {
                self.rightPanLocationInSelf = touchPoint
                self.currentMaxValue = tmpVal
                
                let maxX = self.frame.size.width - self.radius
                if self.currentMaxValue > maxX {
                    self.currentMaxValue = maxX
                }
            }
            self.setNeedsLayout()
        }
        
        self.sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
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
        
        self.leftTracker!.isHighlighted = false;
        self.rightTracker!.isHighlighted = false;
        self.sendActions(for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frameCheck(byView: self.leftTracker!, andFrame: self.leftTrackerRect())
        self.frameCheck(byView: self.rightTracker!, andFrame: self.rightTrackerRect())
        self.frameCheck(byView: self.innerView!, andFrame: self.innerViewRect())
    }
    
    func frameCheck(byView view:UIView, andFrame frame:CGRect) {
        if view.frame != frame {
            UIView.animate(withDuration: 0.0) {
                view.frame = frame
            }
        }
    }
    
    func leftTrackerRect() -> CGRect {
        var frame = self.leftTracker?.frame
        let minX = self.radius
        if self.currentMinValue == minX {
            frame?.origin = self.leftOrigin
        } else {
            frame?.origin.x = self.currentMinValue - self.radius
        }
        return frame!
    }
    
    func rightTrackerRect() -> CGRect {
        var frame = self.rightTracker?.frame
        let maxX = self.frame.size.width - self.radius
        if self.currentMaxValue == maxX {
            frame?.origin = self.rightOrigin
        } else {
            frame?.origin.x = self.currentMaxValue - self.radius
        }
        return frame!
    }
    
    func innerViewRect() -> CGRect {
        var frame = self.innerView!.frame
        frame.origin.x = self.leftTracker!.center.x
        frame.size.width = self.rightTracker!.center.x - frame.origin.x
        return frame
    }
}
