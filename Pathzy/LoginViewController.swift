//
//  LoginViewController.swift
//  Pathzy
//
//  Created by Rens Philipsen on 21-04-16.
//  Copyright © 2016 ExstoDigital. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginUsername.delegate = self
        self.loginPassword.delegate = self
        
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        self.checkLogin(loginUsername.text!, password: loginPassword.text!){ (response:AnyObject) in
            let jsonData = response as? [String: String]
            
            
            if (jsonData!["authentication"] == "true") {
                dispatch_async(dispatch_get_main_queue(), {
                    let user = User(
                        id: Int(jsonData!["id"]!)!,
                        username: jsonData!["name"]!,
                        color: jsonData!["color"]!)
                    
                    self.performSegueWithIdentifier("loggedIn", sender: user)
                })
            } else {
                let alertController = UIAlertController(title: "Pathzy", message:
                    "Username and/or password incorrect!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func checkLogin(username: String, password: String, callback: (AnyObject) -> ()) {
        let url = NSURL(string: "http://pathzy.nl/getlocations.php?username="+username+"&password="+password)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            do
            {
                if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                {
                    callback(jsonObject)
                }
            }
            catch
            {
                print("Error parsing JSON data")
            }
        }
        dataTask.resume()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
}
