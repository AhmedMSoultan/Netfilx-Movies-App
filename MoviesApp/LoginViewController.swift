//
//  LoginViewController.swift
//  MoviesApp
//
//  Created by Ahmed Soultan on 12/02/2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        
        let username = usernameTf.text
        let password = passwordTf.text
        
        let shouldNavigateToHome = verifyUser(userName: username!, password: password!)
        userDefaults.set(shouldNavigateToHome, forKey: "loginState")
        print(shouldNavigateToHome)
        
        if(shouldNavigateToHome){
            let moviesTableVC = storyboard?.instantiateViewController(withIdentifier: "moviesTableVC") as! MoviesTableViewController
            
//            let navigationController = self.window?.rootViewController as! UINavigationController
//                    navigationController.setViewControllers(moviesTableVC, animated: true)
            
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = moviesTableVC
            
            UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: moviesTableVC)
            
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
            
//            let appDelegate = UIApplication.shared.delegate
//            appDelegate?.window??.rootViewController = moviesTableVC
            
//            self.navigationController?.pushViewController(moviesTableVC, animated: true)
            
        }else{
            print("Wrong Username or Password")
        }
    }
    
    func verifyUser(userName:String , password:String) -> Bool{
        if(userName == "Ahmed" && password == "123"){
            return true
        }else{
            return false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
