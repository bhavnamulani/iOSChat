//
//  UsersViewController.swift
//  XMPP
//
//  Created by Ranjit singh on 4/13/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class UsersViewController: BaseViewController {
    
    var userServiceModel: UserServiceModel?
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var usersTableView: UITableView!
    
    @IBAction func logoutActionButton(_ sender: AnyObject) {
        xmppManager.xmppStream.removeDelegate(self)
        xmppManager.xmppStream.disconnect()
        //xmppManager.destroy()
        SharedPref().clearSharedPref()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    let identifier = "userCell"
    var username:String = ""
    var name:String = ""
    var email:String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userServiceModel = UserServiceModel(apiCallback: self)
        userServiceModel!.getUsers()
        // registering user table view nib
        self.usersTableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: self.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        userServiceModel!.setAPICallback(self)
        //this will disable navigation bar from controller when view will appear
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.username = SharedPref().get("username") as! String
        print("self.username",self.username)
        accountNameLabel.text = self.username
        usersTableView.reloadData()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //this will able navigation bar from controller when view will disappear
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Call back method of login
     */
    override func onAPIResponse(_ requestId:Int,isSuccess:Bool,responseObject:AnyObject?,errorString:String?) {
        switch requestId {
        case RequestConstants.REQUEST_FOR_LOGIN:
            self.usersTableView.reloadData()
           // userDo = try! getUsersFromTable()
            break;
        case RequestConstants.REQUEST_FOR_SIGNUP:
            break;
        default: break
        }
    }
    
    /**
     * number Of Rows In Section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDo.count;
    }
    
    
    /**
     * creating cell For Row At Index Path
     */
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        //creating or initiating cell with dequeue Reusable Cell With Identifier
        let cell:UsersTableViewCell! = self.usersTableView.dequeueReusableCell(withIdentifier: self.identifier) as? UsersTableViewCell
        
        //setting name label of custom cell
        let opponentName = userDo[indexPath.row].name
     
        cell.usersNameLabel?.text = opponentName
        
        return cell
    }
    
    /**
     * action for selected Row At Index Path
     */
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = self.usersTableView.cellForRow(at: indexPath) as! UsersTableViewCell
        let userName = cell.usersNameLabel.text
        let lGChatController = LGChatController()
        lGChatController.selfUserDo = userDo[indexPath.row];
        lGChatController.title = userName
        NSLog("did select and the text is \(String(describing: cell.usersNameLabel!.text))")
        self.navigationController?.pushViewController(lGChatController, animated: true)
    }
    
    /**
     * estimatedHeightForRowAtIndexPath method which return each cell to table view
     */
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
}
