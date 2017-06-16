import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView! {
        didSet{
            userImageView.layer.cornerRadius = 20
            userImageView.isUserInteractionEnabled = true
        }
    }
   
    
    
    @IBOutlet weak var firstLastNameTextField: UITextField!{
        didSet{
            firstLastNameTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            firstLastNameTextField.attributedPlaceholder = NSAttributedString(string: "NOME COMPLETO",
                                                                              attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var addressTextField: UITextField!{
        didSet{
        addressTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            addressTextField.attributedPlaceholder = NSAttributedString(string: "ENDEREÇO",
                                                                        attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }
    
    @IBOutlet weak var usernameTextField: UITextField!{
        didSet{
            usernameTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            usernameTextField.attributedPlaceholder = NSAttributedString(string: "NOME DO USUÁRIO",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }
    @IBOutlet weak var cnpjTextField: UITextField!{
        didSet{
            cnpjTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            cnpjTextField.attributedPlaceholder = NSAttributedString(string: "CNPJ",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }
    
    
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            emailTextField.attributedPlaceholder = NSAttributedString(string: "CONTATO@MAIL.COM",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var biographyTextField: UITextField!{
        didSet{
            biographyTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            biographyTextField.attributedPlaceholder = NSAttributedString(string: "DESCRICAO",
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    
    @IBOutlet weak var categoryTextField: UITextField!{
        didSet{
            categoryTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
                 categoryTextField.attributedPlaceholder = NSAttributedString(string: "CATEGORIA",
                                                            attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var passwordTextField: UITextField!{
        didSet{
            passwordTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.gray, thickness: 2)
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "•••••••",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        let screenWidth = UIScreen.main.bounds.size.width as CGFloat
        let contentHeight = signUpButton.frame.maxY + 50
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)
        
    }
    
    var pickerView: UIPickerView!
    var categoryArrays = [String]()
    var authService = AuthService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPickerView()
        setGestureRecognizersToDismissKeyboard()
        retrievingCategory()
        
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenWidth = UIScreen.main.bounds.size.width as CGFloat
        let contentHeight = signUpButton.frame.maxY + 50
        scrollView.contentSize = CGSize(width: screenWidth, height: contentHeight)

    }
    
    func showMessage() {
        
        let alertController = UIAlertController(title: "OOPS", message: "A user with the same username already exists. Please choose another one", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    @IBAction func signUpAction(sender: UIButton) {
        
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = categoryTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let address = addressTextField.text!
        let cnpj = cnpjTextField.text!
        let password = passwordTextField.text!
        let firstLastName = firstLastNameTextField.text!
        let pictureData = UIImageJPEGRepresentation(self.userImageView.image!, 0.70)
        
        if finalEmail.isEmpty || category.isEmpty || biography.isEmpty || address.isEmpty || username.isEmpty || cnpj.isEmpty || password.isEmpty {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Campos Vazios", message: "Preencha todos os campos por favor.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }else {
            self.view.endEditing(true)
            authService.signUp(firstLastName: firstLastName, username: username, address: address, cnpj: cnpj, email: finalEmail, category: category, biography: biography, password: password, pictureData: pictureData as NSData!)
            
        }
 
    }
    
   }



//--------------------------------------------------------------------------------------------------------------------

extension SignUpViewController: UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setUpPickerView(){
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)

        categoryTextField.inputView = pickerView
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
        addressTextField.resignFirstResponder()
        cnpjTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        categoryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        scrollView.contentOffset.y = textField.frame.origin.y
        
        //animateView(up: true, moveValue: 45)
    }
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        scrollView.contentOffset.y = 0
        
        //animateView(up: false, moveValue: 45)
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
        categoryTextField.text = categoryArrays[row]
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
