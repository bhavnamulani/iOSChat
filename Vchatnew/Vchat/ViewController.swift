//
//  ViewController.swift
//  Vchat
//
//  Created by ranjit singh on 5/2/17.
//  Copyright © 2017 ranjit singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let loginVC = SigninViewController(nibName: "SigninViewController", bundle: nil)
        let navigationVC = UINavigationController(rootViewController: loginVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    

}

