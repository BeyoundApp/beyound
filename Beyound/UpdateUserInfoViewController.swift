//
//  UpdateUserInfoViewController.swift
//  MaranathApp
//
//  Created by Frezy Stone Mboumba on 8/12/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UpdateUserInfoViewController: UIViewController {
    @IBAction func LogoutAction(_ sender: Any) {
        if FIRAuth.auth()!.currentUser != nil {
            // there is a user signed in
            do {
                try? FIRAuth.auth()!.signOut()
                
                if FIRAuth.auth()?.currentUser == nil {
                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                    self.present(loginVC, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!{
        didSet {
            userImageView.layer.cornerRadius = 5
            userImageView.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var usernameTextField: UITextField!{
        didSet{
            usernameTextField.layer.cornerRadius = 5
            usernameTextField.delegate = self
        }
    }

    @IBOutlet weak var biographyTextField: UITextField!{
        didSet{
            biographyTextField.layer.cornerRadius = 5
            biographyTextField.delegate = self
        }
    }
    
    @IBOutlet weak var countryTextField:UITextField!{
        didSet{
            countryTextField.layer.cornerRadius = 5
            countryTextField.delegate = self
        }
    }

    
    @IBOutlet weak var updateButton: UIButton! {
        didSet{
            updateButton.layer.cornerRadius = 5
            updateButton.layer.borderWidth = 1
            updateButton.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1).cgColor
        }
    }
    
    var pickerView: UIPickerView!
    var categoryArrays = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setUpPickerView()
        setGestureRecognizersToDismissKeyboard()
        retrievingCategory()
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func loadUserInfo(){
        
        }



    
    @IBAction func updateInfoAction(sender: UIButton) {
    }

        
    }
    
extension UpdateUserInfoViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setUpPickerView(){
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        
        countryTextField.inputView = pickerView
    }
    
    func setGestureRecognizersToDismissKeyboard(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.choosePictureAction(sender:)))
        imageTapGesture.numberOfTapsRequired = 1
        userImageView.addGestureRecognizer(imageTapGesture)
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    func retrievingCategory(){
        let category: [String] = ["Academia de Esportes/Artes Marciais", "Administração e Participação", "Agricultura/Pecuária", "Arquitetura/Urbanismo", "Automação", "Bancário/Financeiro", "Bens de Capital", "Calçados", "Comércio Varejista", "Consultoria Geral", "Corretagem", "Diversão/Entreterimento", "Editora", "Eletroeletrônica", "Energia", "Equipamentos industriais", "Estética/Academia", "Farmacêutica", "Gráfica", "Incorporadora", "Informática", "Jornais", "Logística", "Mecânica/Manuntenção", "Mineração", "ONGs", "Órgãos Públicos", "Papel e derivados", "Plásticos", "Publicidade e Propaganda", "Relações Públicas", "Restaurante", "Sindicatos/Associações", "Telecomunicações", "Têxtil", "Turismo/Hotelaria", "Veterinária"]
        
        for name in category{
            categoryArrays.append(name)
        }
    }
    
    func choosePictureAction(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Adicione uma Imagem de Perfil", message: "Escolha de", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Biblioteca de Fotos", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Álbum de Fotos Salvas", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            self.userImageView.image = image
        }else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToLogin(storyboard: UIStoryboardSegue){}
    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 45)
    }
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue: 45)
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
    
    // MARK: - Picker view data source
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = categoryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArrays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: categoryArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return title
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = categoryArrays[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18.0)!,NSForegroundColorAttributeName: UIColor.white])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
        
    }
    
    
    
}
