//
//  ChooseUserViewController.swift
//  beyound
//
//  Created by Daniela Pereira on 22/02/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!{
        didSet {
            signUpButton.layer.cornerRadius = 25
            signUpButton.layer.borderWidth = 1
            signUpButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1).cgColor
        }
    }
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTextField: UITextField!{
        didSet {
            emailTextField.delegate = self
            emailTextField.layer.cornerRadius = 25
            emailTextField.layer.masksToBounds = true
            emailTextField.layer.borderColor = UIColor( red: 255/255, green: 255/255, blue:255/255, alpha: 1.0 ).cgColor
            emailTextField.layer.borderWidth = 3

        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField!{
        didSet {
            passwordTextField.delegate = self
            passwordTextField.layer.cornerRadius = 25
            passwordTextField.layer.masksToBounds = true
            passwordTextField.layer.borderColor = UIColor( red: 255/255, green: 255/255, blue:255/255, alpha: 1.0 ).cgColor
            passwordTextField.layer.borderWidth = 3.0
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 25
            loginButton.layer.backgroundColor = UIColor( red: 255/255, green: 255/255, blue:255/255, alpha: 1.0 ).cgColor
        }
    }

    @IBOutlet weak var registerButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let screenWidth = UIScreen.main.bounds.size.width as CGFloat
        let contentHeight = registerButton.frame.maxY + 50
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGestureRecognizersToDismissKeyboard()
        
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenWidth = UIScreen.main.bounds.size.width as CGFloat
        let contentHeight = registerButton.frame.maxY + 50
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)
        
    }
    
    @IBAction func resetPasswordAction(sender: UIButton) {
        self.view.endEditing(true)
        resetPassword()
        
        }

    var authService = AuthService()
    
    @IBAction func loginAction(sender: UIButton) {
        self.view.endEditing(true)

        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!

        if finalEmail.characters.count < 8 || finalEmail.isEmpty || password.isEmpty {
            
            let alertController = UIAlertController(title: "OOPS", message: "hEY MAN, You gotta fill all the fields", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }else {
            
            authService.logIn(email: finalEmail, password: password)
        }
        }
    
    
}

//----------------------------------------------------------------------------------------------------------------------//

extension LoginViewController: UITextFieldDelegate  {
    
    @IBAction func unwindToLogin(storyboard: UIStoryboardSegue){}
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.contentOffset.y = 45

        //animateView(up: true, moveValue: 80)
    }
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.contentOffset.y = 0

        //animateView(up: false, moveValue: 80)
    }
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
    }
    
    func setGestureRecognizersToDismissKeyboard(){
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    
}
