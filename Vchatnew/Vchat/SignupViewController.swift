//
//  SignupViewController.swift
//  XMPP
//
//  Created by Ranjit singh on 4/13/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class SignupViewController: BaseViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupScrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var userServiceModel: UserServiceModel?
    /**
     * Signup button action
     */
    @IBAction func signupActionButton(_ sender: AnyObject) {
        let name:String = nameTextField.text!
        let username:String = userNameTextField.text!
        let password:String = passwordTextField.text!
        let email:String = emailTextField.text!
        
        if validateSignup(name, username: username, password: password, email: email){
            let params = ["name":name, "username":username, "password":password, "email":email]
            let usersServiceModel = UserServiceModel(apiCallback: self)
            usersServiceModel.signup(name, username:username, password:password, email:email, json:params as [String : AnyObject])
            //self.navigationController?.popViewController(animated: true)
        }
        else{
            print("signup fail")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userServiceModel = UserServiceModel(apiCallback: self)
        //Applying border radious to login button
        signupButton.layer.cornerRadius = 15
        
        // creating instance of Tap guesture recogniser
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //This brodcaster will brodcast show keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        //This brodcaster will brodcast hide keyboard notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    /**
     * override func viewDidAppear
     */
    override func viewDidAppear(_ animated: Bool) {
        userServiceModel!.setAPICallback(self)
        //Setting scrolling height and width of scrollview
        signupScrollView.contentSize = CGSize(width: 0,height: 500);
        //disabling aucorrection of textfield
        nameTextField.autocorrectionType = .no
        userNameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        emailTextField.autocorrectionType = .no
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Call back method of signup
     */
    override func onAPIResponse(_ requestId:Int,isSuccess:Bool,responseObject:AnyObject?,errorString:String?) {
        switch requestId {
        case RequestConstants.REQUEST_FOR_LOGIN:
            break;
        case RequestConstants.REQUEST_FOR_SIGNUP:
            //creating arert view
            let alert = UIAlertController(title: "SignUp Success", message: "Please Login Now", preferredStyle: UIAlertControllerStyle.alert)
            //presenting alert view
            self.present(alert, animated: true, completion: nil)
            //action of alert view after clicking ok button
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    self.navigationController?.popViewController(animated: true)
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                }
            }))
            break;
        default: break
        }
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
        
        var contentInset:UIEdgeInsets = self.signupScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.signupScrollView.contentInset = contentInset
    }
    
    /**
     * This funtion is called by show keyboard brodcast
     */
    func keyboardWillHide(_ notification:Notification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.signupScrollView.contentInset = contentInset
    }
    
    /**
     * This funtion validate signup data
     */
    func validateSignup(_ name:String, username: String, password: String, email: String)-> Bool{
        
        if name == "" || username == "" || password == "" || email == "" {
            return false
        }
        else{
            return true
        }
    }
}

