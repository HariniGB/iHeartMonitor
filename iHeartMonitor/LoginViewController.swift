//
//  LoginViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import Charts
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!

    @IBAction func login(_ sender: UIButton) {
        if let email = userName.text, let password = userPassword.text{
            
            Auth.auth().signIn(withEmail: email, password:password, completion:{(user, error) in
                if let firebaseError = error{
                    // create the alert
                    let alert = UIAlertController(title: "Wrong Credentials", message: firebaseError.localizedDescription , preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    return
                }
                //self.presentLoggedInScreen()
                //print("sucess")
                self.goToHome()
            })
            
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToHome(){
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarViewController") as! TabBarViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
