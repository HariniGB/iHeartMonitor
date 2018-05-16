//
//  LoginViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!

  
    @IBAction func login(_ sender: UIButton) {
        if let email = userName.text, let password = userPassword.text{
            
            Auth.auth().signIn(withEmail: email, password:password, completion:{(user, error) in
                if let firebaseError = error{
                    let alertView = UIAlertController(title: "Invalid Email or Password", message: firebaseError.localizedDescription, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertView, animated:true, completion:nil)
                    print(firebaseError.localizedDescription)
                    return
                }
                //self.presentLoggedInScreen()
                //print("sucess")
                self.goToHome()
            })
            
        }
        
    }
    var handle: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self as GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signInSilently()
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if user != nil {
            MeasurementHelper.sendLoginEvent()
            self.goToHome()
            }
        }
        // Do any additional setup after loading the view.
    }
   
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    

    @IBOutlet weak var signInButton: GIDSignInButton!
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
