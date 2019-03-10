import Foundation

extension Date
{
    ///这个月有多少天
    func numberOfDaysAtCurrentMonth() -> Int
    {
        let range = NSCalendar.current.range(of: .day, in: .month, for: self)
        return NSRange(range!).length
    }
    
    private func weeklyOrdinality() -> Int
    {
        return NSCalendar.current.ordinality(of: .day, in: .month, for: self)!
    }
    
    static func initDate(year:Int,month:Int,day:Int) -> Date?
    {
        let component = NSDateComponents()
        component.year = year
        component.month = month
        component.day = 1
        component.hour = 0
        component.minute = 0
        component.second = 0
        
        return NSCalendar(calendarIdentifier: .gregorian)?.date(from: component as DateComponents)
    }
    
    enum AccurateTimeType : Int
    {
        case Year = 0
        case Month = 1
        case Day = 2
        case Hour = 3
        case Minute = 4
        case Second = 5
    }
    
    func accurateTime(type : AccurateTimeType) -> String?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd-HH-mm-ss"
        let localStr = dateFormatter.string(from: self)
        let arr = localStr.components(separatedBy: "-")
        return type.rawValue < arr.count ? arr[type.rawValue] : nil
    }
    
    ///确定这个月的第一天是星期几。这样就能知道给定月份的第一周有几天：
    func firstDayOfCurrentMonth() -> Date?
    {
        var startDate : NSDate?
        let calendar = NSCalendar.current as NSCalendar
        calendar.range(of: .month, start: &startDate, interval: nil, for: self)
        return startDate as Date?
    }
    
    ///表上的一个月有几周
    func numberOfWeeksInCurrentMonth() -> Int
    {
        let weekday = self.firstDayOfCurrentMonth()?.weeklyOrdinality()
        var days = self.numberOfDaysAtCurrentMonth()
        var weeks = 0
        if (weekday! > 1)
        {
            weeks += 1
            days -= (7 - weekday! + 1)
        }
        weeks += days / 7
        weeks += (days % 7 > 0) ? 1 : 0
        return weeks;
    }
    
    ///X年X月有几天
    static func daysOfMonth(year : Int,month : Int) -> Int
    {
        let date = Date.initDate(year: year, month: month, day: 1)
        return (date?.numberOfDaysAtCurrentMonth())!
    }
    
    ///X年X月X日是周几 (周日:0)
    static func numberOfDay(year : Int,month : Int,day : Int) -> Int 
    {
        let date = Date.initDate(year: year, month: month, day: day)
        let gregorian = NSCalendar(identifier: .gregorian)
        let weekdayComponents = gregorian?.components(.weekday, from: date! as Date)
        return weekdayComponents!.weekday!
    }
}
