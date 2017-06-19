import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UpdateUserInfoViewController: UIViewController {
  
    
    
    @IBOutlet weak var userImageView: UIImageView!{
        didSet {
            userImageView.layer.cornerRadius = 25
            userImageView.isUserInteractionEnabled = true
        }
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    {
        didSet{
            usernameTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.white, thickness: 2)
            usernameTextField.attributedPlaceholder = NSAttributedString(string: "NOME DE USUÁRIO",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var biographyTextField: UITextField!{
        didSet{
            biographyTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.white, thickness: 2)
            biographyTextField.attributedPlaceholder = NSAttributedString(string: "DESCRIÇÄO",
                                                                          attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }
    
    @IBOutlet weak var countryTextField:UITextField!{
        didSet{
            countryTextField.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.white, thickness: 2)
            countryTextField.attributedPlaceholder = NSAttributedString(string: "RAMO DE ATIVIDADE",
                                                                          attributes: [NSForegroundColorAttributeName: UIColor.gray])
        }
    }

    @IBOutlet weak var firstLastName: UITextField!{
        didSet{
            firstLastName.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.white, thickness: 2)
            firstLastName.attributedPlaceholder = NSAttributedString(string: "RAMO DE ATIVIDADE",
                                                                        attributes: [NSForegroundColorAttributeName: UIColor.gray])
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
        loadUserInfo()
        
    }
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        
        return FIRStorage.storage()
    }
    
    var storageRefi: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }

    
    
    func loadUserInfo(){
        
        let userRef = dataBaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            
            Singleton.sharedInstance.setUserLoggedId(id: user.uid)
            Singleton.sharedInstance.setUserLoggedName(name: user.username!)
            Singleton.sharedInstance.setUserLoggedEmail(email: user.email!)
            Singleton.sharedInstance.setUserLoggedCnpj(cnpj: user.cnpj)
            
            self.usernameTextField.text = user.username!
            self.countryTextField.text = user.category!
            self.biographyTextField.text = user.biography!
            self.firstLastName.text = user.firstLastName
            let imageURL = user.photoURL!
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.userImageView.image = UIImage(data: data)
                        }
                    }
                    
                }else {
                    print(error!.localizedDescription)
                    
                }
                
                
            })

            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }


    @IBAction func updateInfoAction(_ sender: Any) {
        
        let username = usernameTextField.text!
        let categoria = countryTextField.text!
        let descricao = biographyTextField.text!
        let first = firstLastName.text!
        
        let pictureData = UIImageJPEGRepresentation(self.userImageView.image!, 0.70)!
        
        
        
        
        if categoria.isEmpty || descricao.isEmpty || username.isEmpty {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Campos Vazios", message: "Preencha todos os campos por favor.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }else {
            let userRef = dataBaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
            userRef.observe(.value, with: { (snapshot) in
                
                let user = User(snapshot: snapshot)
                
                Singleton.sharedInstance.setUserLoggedId(id: user.uid)
                Singleton.sharedInstance.setUserLoggedName(name: user.username!)
                Singleton.sharedInstance.setUserLoggedEmail(email: user.email!)
                Singleton.sharedInstance.setUserLoggedCnpj(cnpj: user.cnpj)
                
                let id = user.uid!
                let cnpj = user.cnpj!
                let endereco = user.address!
                let email = user.email!
                
                let imagePath = "profileImage\(id)/userPic.jpg"
                
                let imageRef = self.storageRefi.child(imagePath)
                
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                
                imageRef.put(pictureData, metadata: metaData) { (newMetaData, error) in
                    
                    if error == nil {
                        
                        let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                        changeRequest.displayName = username
                        
                        if let photoURL = newMetaData!.downloadURL() {
                            changeRequest.photoURL = photoURL
                        }
                        
                        changeRequest.commitChanges(completion: { (error) in
                            if error == nil {
                                
                                let userInfo = ["firstLastName": first,"email": email, "username": username, "address": endereco, "cnpj":cnpj, "category": categoria, "biography":descricao, "uid": user.uid, "photoURL": String(describing: user.photoURL!)]
                                
                                //                            let userRefi = self.dataBaseRef.child("users").child(user.uid)
                                
                                userRef.setValue(userInfo)
                                
                            }else{
                                print(error!.localizedDescription)
                                
                            }
                        })
                        
                        
                    }
                    else {
                        print(error!.localizedDescription)
                    }
                    
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
        }
        
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
