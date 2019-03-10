import UIKit

public enum LockCodeStatus
{
    case codeCreat
    case codeCheck
    case codeClean
}

public let LockCodeKey : String = "lockCodeKey"

class LockViewController: UIViewController
{
    open var status : LockCodeStatus?
    
    fileprivate var tipLabel : UILabel?
    fileprivate var indicator : Indicator?
    fileprivate var lockView : LockView?
    fileprivate var resetBt : UIButton?
    fileprivate var isCorrect : Bool = false
    fileprivate var isClean : Bool = false
    fileprivate var isCreat : Bool = false
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CodeFinishNotification), object: nil)
    }
    
    @objc private func confirm(tap : UITapGestureRecognizer)
    {
        var msg : String?
        if self.status == LockCodeStatus.codeCheck
        {
            msg = self.isCorrect ?"密码输入成功":"密码输入失败";
        }
        else if self.status == LockCodeStatus.codeClean
        {
            msg = self.isClean ?"密码清除成功":"密码清除失败"
        }
        else
        {
            msg = self.isCreat ?"密码创建成功":"密码创建失败"
        }
        self.showMessage(msg: msg!)
    }
    
    private func showMessage(msg : String)
    {
        let alert = UIAlertController(title: "消息", message: msg, preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:
        { action in
            if self.isCorrect || self.isClean || self.isCreat
            {
                self.dismiss(animated: true)
            }
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        let width = UIScreen.main.bounds.size.width

        self.tipLabel = UILabel(frame: CGRect(x: 0, y: 20, width: width, height: 40))
        self.tipLabel?.isUserInteractionEnabled = true
        self.tipLabel?.numberOfLines = 0
        self.tipLabel?.textAlignment = NSTextAlignment.center
        self.tipLabel?.textColor = UIColor.lightGray
        self.view.addSubview(self.tipLabel!)

        let tap = UITapGestureRecognizer(target: self, action: #selector(confirm(tap:)))
        self.tipLabel?.addGestureRecognizer(tap)

        self.indicator = Indicator(frame: CGRect(x: width/2-25, y: (self.tipLabel?.frame.origin.y)!+(self.tipLabel?.frame.size.height)!+10, width: 50, height: 50))
        self.indicator?.backgroundColor = UIColor.white
        self.indicator?.layer.cornerRadius = 10.0
        self.indicator?.layer.masksToBounds = true
        self.indicator?.layer.borderColor = UIColor.black.cgColor
        self.indicator?.layer.borderWidth = 1.0
        self.view.addSubview(self.indicator!)
        
        self.lockView = LockView(frame: CGRect(x: 0.05*width, y: (self.indicator?.frame.origin.y)!+50+20, width: 0.9*width, height: 0.55*UIScreen.main.bounds.size.height))
        self.lockView?.backgroundColor = UIColor.white
        self.lockView?.layer.masksToBounds = true
        self.lockView?.layer.cornerRadius = 10.0
        self.lockView?.layer.borderColor = UIColor.black.cgColor
        self.lockView?.layer.borderWidth = 1.0
        self.view.addSubview(self.lockView!)
        
        self.resetBt = UIButton(type: UIButton.ButtonType.custom)
        self.resetBt?.frame = CGRect(x: 0, y: (self.lockView?.frame.origin.y)!+(self.lockView?.frame.size.height)!+30, width: width, height: 40)
        self.resetBt?.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        self.resetBt?.setTitleColor(UIColor.red, for: UIControl.State.highlighted)
        self.resetBt?.titleLabel?.textAlignment = NSTextAlignment.center
        self.resetBt?.setTitle("点击此处重新设置", for: UIControl.State.normal)
        self.resetBt?.addTarget(self, action: #selector(reset), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.resetBt!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(endDrawing(noti:)), name: Notification.Name(CodeFinishNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func endDrawing(noti : Notification)
    {
        self.indicator?.refresh(noti.object as! String)
        
        if self.status == LockCodeStatus.codeCreat
        {
            self.tipLabel!.text = "确定"
            self.isCreat = true
        }
        else if self.status == LockCodeStatus.codeCheck
        {
            if self.lockView?.isDone == true
            {
                self.tipLabel?.text = "确定"
                let lastCode = UserDefaults.standard.object(forKey: LockCodeKey) as! String
                if lastCode == (noti.object as! String)
                {
                    self.isCorrect = true
                }
            }
        }
        else
        {
            if self.lockView?.isClean == true
            {
                self.tipLabel?.text = "确定"
                let lastCode = UserDefaults.standard.object(forKey: LockCodeKey) as! String
                if lastCode == (noti.object as! String)
                {
                    UserDefaults.standard.removeObject(forKey: LockCodeKey)
                    self.isCorrect = false
                    self.isClean = true
                }
            }
        }
    }
    
    @objc private func reset()
    {
        self.indicator?.refresh(refreshCmd)
        self.lockView?.refreshLockView()
        self.tipLabel?.text = self.status == LockCodeStatus.codeCreat ?"创建密码":"输入密码"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.reset()
        if self.status == LockCodeStatus.codeCreat
        {
            self.lockView?.codeStatus = "creat"
            UserDefaults.standard.removeObject(forKey: LockCodeKey)
            self.tipLabel?.text = "创建密码"
        }
        else if self.status == LockCodeStatus.codeClean
        {
            self.lockView?.codeStatus = "clean"
            self.tipLabel?.text = "输入密码"
        }
        else if self.status == LockCodeStatus.codeCheck
        {
            self.lockView?.codeStatus = "check"
            self.tipLabel?.text = "输入密码"
        }
    }
}
