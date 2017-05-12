//
//  SigninViewController.swift
//  XMPP
//
//  Created by Ranjit singh on 4/13/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit
import XMPPFramework

class SigninViewController: BaseViewController, XMPPConnectCallback {
    
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinScrollView: UIScrollView!
    
    /**
     * signup button aciton signup
     */
    @IBAction func signupActionButton(_ sender: AnyObject) {
        let signupVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
        self.navigationController?.pushViewController(signupVC, animated: true )
    }
    
    /**
     * signin button aciton signin
     */
    @IBAction func signinActionButton(_ sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if self.validateLogin(username!, password:password!){
            //Will check if username contain "@test-pc", if not then will append it
            if ((username?.lowercased().range(of: "@test-pc")) != nil){
                
                if xmppManager == nil {
                    //using object of singleton class
                    xmppManager = XMPPManager(uid: username!, pass:password!)
                    xmppManager.connect(self)
                }else{
                    xmppManager.connect(self)
                }

            }
            else{
                
                let appendedUserName = username!+"@test-pc"
                //using object of singleton class
                if xmppManager == nil {
                    xmppManager = XMPPManager(uid: appendedUserName, pass:password!)
                    xmppManager.connect(self)
                }else{
                    xmppManager.connect(self)
                }
                
            }
        }else{
            print("One or both of fields are empty")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userServiceModel = UserServiceModel(apiCallback: self)
        //This brodcaster will brodcast show keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        //This brodcaster will brodcast hide keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // creating instance of Tap guesture recogniser
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Applying border radious to login button
        loginButton.layer.cornerRadius = 15
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //this will disable navigation bar from controller when view will appear
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //this will disable autocorrection of keyboard of usernameTextField and passwordTextField
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //this will able navigation bar from controller when view will disappear
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Setting scrolling height and width of scrollview
        //userServiceModel!.setAPICallback(self)
        signinScrollView.contentSize = CGSize(width: 0,height: 400);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * This funtion will dismiss Keyboard called by instance of Tap guesture recogniser
     */
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /**
     * This funtion is called by show keyboard brodcast
     */
    func keyboardWillShow(_ notification:Notification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.signinScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.signinScrollView.contentInset = contentInset
    }
    
    /**
     * This funtion is called by show keyboard brodcast
     */
    func keyboardWillHide(_ notification:Notification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.signinScrollView.contentInset = contentInset
    }
    
    /**
     * Empty validation on fileds
     */
    func validateLogin(_ username:String, password: String)-> Bool{
        print("validateData")
        if username == "" || password == ""{
            return false
        }
        else{
            return true
        }
    }
    
    /**
     * Shows connection responce
     */
    func onXMPPConnectResponse(_ isSuccess: Bool, message: String, username: String, pwd: String) {
        if(isSuccess)
        {
            print("Message : \(message) Username : \(username)")
            SharedPref().clearSharedPref()
            SharedPref().put("username", value:username as AnyObject)
            //making UsersViewController as root navigation controller
            let usersVC = UsersViewController()
            let navigationVC = UINavigationController(rootViewController: usersVC)
            self.present(navigationVC, animated: true, completion: nil)
            
        }else{
            print(message)
        }
    }
    
    
}
