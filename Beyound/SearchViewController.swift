//
//  SearchViewController.swift
//  Beyound
//
//  Created by Elder Santos on 13/04/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var navItem: UINavigationItem!
       @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var buttonSearch: UIButton!
    
    var wordsLoaded : Bool = false
    
    var allWords: NSMutableDictionary!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        allWords = NSMutableDictionary()
        
        self.getScores(){(completion) -> () in
            if(completion == nil){
                self.wordsLoaded = true
                self.buttonSearch.isEnabled = !(self.textField.text?.isEmpty)!
            }
        }
    }

    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textChanged(_ sender: Any) {

        buttonSearch.isEnabled = !(textField.text?.isEmpty)!
    }
    

    func getScores(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/scores.json"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var err: NSError?
            var string = String(data: data!, encoding: .utf8)
            
            if string == "null\n"{
                
                completion(nil)
                
            }else{
                
                do{
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        self.allWords = jsonResult.mutableCopy() as! NSMutableDictionary
                        completion(nil)
                    }
                }catch let error as NSError{
                    print(error)
                    completion(nil)
                }
                
            }
        })
        task.resume()
    }

    
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "searchToResult", sender: self)
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let searchResultController = segue.destination as! SearchResultController
        
        var query = NSMutableArray()
       
        let components = textField.text!.components(separatedBy: CharacterSet.init(charactersIn: " ,.;:\n#@"))
        
        for var i in (0..<components.count){
        
            query.add(components[i].lowercased())
        }

        searchResultController.allWords = self.allWords
        searchResultController.queryTags = query
    }
 

}
