//
//  QuestionViewController.swift
//  Beyound
//
//  Created by Elder Santos on 10/03/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var labelQuestionTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fieldTag: UITextField!
    @IBOutlet weak var buttonAdd: UIButton!
    
    var page: Int!
    var question : String?
    
    var tags = [String]()
    var totalQuestions :Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        
        var nib = UINib(nibName: "TagViewCell", bundle:nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "TagCell");
        
        self.navigationItem.title = "Pergunta \(page!) de \(totalQuestions)"
        
        tags = ["Prema", "Photography", "Design", "Humor", "Love Traveling", "Music", "Writing", "Easy Life", "Education", "Engineer", "Startup", "Funny", "Women In Tech", "Female", "Business", "Songs", "Love", "Food", "Sports"]
        
        //colocar titulo da pergunta
        //labelQuestionTitle.text = dictPlist[page]
        
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(QuestionViewController.hideKeyboard));
        touch.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(touch)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
    }

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height

        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func hideKeyboard(){
        view.endEditing(true);
    }
    
    @IBAction func goToNextQuestion(_ sender: Any) {
        
        let indexPaths = collectionView.indexPathsForSelectedItems
        
        for item in indexPaths! {
            
            print(tags[item.row])
            
        }
        
        
        
        if(page == totalQuestions){
            
            //encerra formulario
            
        }else{
            
            var nextQuestion = self.storyboard?.instantiateViewController(withIdentifier: "questionController") as! QuestionViewController
            
            nextQuestion.page = self.page+1
            self.navigationController?.pushViewController(nextQuestion, animated: true)

        }
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let textSize = (tags[indexPath.row] as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0)]) as CGSize
        //dando um paddingzinho
        
        var tagSize = CGSize()
    
        tagSize.width = textSize.width + 20
        tagSize.height = textSize.height + 8
        
        return tagSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagViewCell
        
        cell.tagName.text = tags[indexPath.row]
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
    
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var cell = collectionView.cellForItem(at: indexPath) as! TagViewCell

        cell.isMarked = true
        cell.contentView.backgroundColor = UIColor.green
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        var cell = collectionView.cellForItem(at: indexPath) as! TagViewCell

        cell.isMarked = false
        cell.contentView.backgroundColor = UIColor.blue
        
    }
    
    @IBAction func addNewTag(_ sender: Any) {
        
        if((fieldTag.text?.characters.count)! > 0){
            tags.append(fieldTag.text!)
            fieldTag.text = ""
            collectionView.reloadData()
            self.hideKeyboard()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if((fieldTag.text?.characters.count)! > 0){
            tags.append(fieldTag.text!)
            fieldTag.text = ""
            collectionView.reloadData()
            self.hideKeyboard()
        }
        
        return true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
