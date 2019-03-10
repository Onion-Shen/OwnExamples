import UIKit

class CalendarView: UIView
{
    fileprivate var year : Int = 0
    fileprivate var month : Int = 0
    fileprivate var title : UILabel?
    fileprivate var cache : [CalendarItem] = []
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        for _ in 0 ..< 31
        {
            self.cache.append(CalendarItem(frame: CGRect.zero))
        }
        
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 2

        for i in 0 ..< 2
        {
            let swipe = UISwipeGestureRecognizer(target: self ,action: #selector(changeMonth))
            swipe.direction = UISwipeGestureRecognizer.Direction(rawValue: UInt(1 << i))
            self.addGestureRecognizer(swipe)
        }
        
        self.createNav()
        self.createMainView(Date())
    }
    
    @objc fileprivate func changeMonth(_ swipe : UISwipeGestureRecognizer)
    {
        let transition = CATransition()
        transition.duration = 0.4
        
        if (swipe.direction == .right)
        {
            transition.type = CATransitionType(rawValue: "pageUnCurl")
            if (self.month > 1)
            {
                self.month -= 1
            }
            else
            {
                self.month = 12
                self.year -= 1
            }
        }
        else
        {
            transition.type = CATransitionType(rawValue: "pageCurl")
            if (self.month < 12)
            {
                self.month += 1
            }
            else
            {
                self.month = 1
                self.year += 1
            }
        }
        
        self.title?.text = "\(self.year).\(self.month)"
        self.changeMainView()
        self.layer.add(transition, forKey: "page")
    }
    
    fileprivate func createMainView(_ date : Date)
    {
        ///当前月份的第一天是周几,周日是1
        var firstDay = Date.numberOfDay(year: self.year, month: self.month, day: 1)
        if firstDay > 0
        {
            firstDay -= 1
        }
        
        ///当前月份的天数
        let days = Date.daysOfMonth(year: self.year, month: self.month)
        
        let sum = days + firstDay 
        let reminder = sum % 7
        let lines = sum / 7 + (reminder == 0 ? 0 : 1)
        
        let width = self.frame.size.width / 7
        let height = (0.8 * self.frame.size.height) / CGFloat(lines)
        var index = 0
        
        for week in 0 ..< lines 
        {
            for day in 0 ..< 7
            {
                var validDay = true
                
                if week == 0
                {
                    if day < firstDay
                    {
                        validDay = false
                    }
                }
                else 
                {
                    if index == days 
                    {
                        validDay = false
                    }
                }
               
                if !validDay 
                {
                    continue
                }
                
                let x = CGFloat(day) * width
                let y = 0.2 * self.frame.size.height + CGFloat(week) * height
                let rect = CGRect(x: x, y: y, width: width, height: height)
                
                let cell = cache[index]
                cell.year = self.year
                cell.month = self.month
                cell.day = index + 1
                cell.contentLabel.text = "\(cell.day)"
                cell.frame = rect
                
                self.addSubview(cell)
                
                index += 1
            }
        }

    }
    
    fileprivate func createNav()
    {
        let nav = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.2 * self.frame.size.height))
        
        self.title = UILabel(frame: CGRect(x: 0, y: 0, width: nav.frame.size.width, height: 0.5 * nav.frame.size.height))
        self.title?.textAlignment = .center
        let currentDate = Date()
        self.year = Int(currentDate.accurateTime(type: .Year)!)!
        self.month = Int(currentDate.accurateTime(type: .Month)!)!
        self.title?.text = "\(self.year).\(self.month)"
        nav.addSubview(self.title!)
        
        let arr = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        let width = nav.frame.size.width / 7
        let height = 0.5 * nav.frame.size.height
        let y = self.title!.frame.size.height
        for (i,v) in arr.enumerated()
        {
            let x : CGFloat = (CGFloat)(i) * width
            let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            label.layer.borderColor = UIColor.black.cgColor
            label.layer.borderWidth = 0.25
            label.textAlignment = .center
            label.text = "\(v)"
            nav.addSubview(label)
        }
        
        self.addSubview(nav)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func changeMainView()
    {
        _ = cache.map { $0.removeFromSuperview() }
        let newDate = Date.initDate(year: self.year, month: self.month, day: 1)
        self.createMainView(newDate!)
    }
}
