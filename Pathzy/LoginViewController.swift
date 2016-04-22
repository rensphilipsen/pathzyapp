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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        self.checkLogin(loginUsername.text!, password: loginPassword.text!){ (response:AnyObject) in
            let jsonData = response as? [String: AnyObject]
            
            var signedIn = false
            signedIn = (jsonData!["authentication"]?.boolValue)!
            
            if (signedIn) {
                self.performSegueWithIdentifier("loggedIn", sender: self)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
