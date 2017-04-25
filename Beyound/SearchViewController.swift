//
//  SearchViewController.swift
//  Beyound
//
//  Created by Elder Santos on 13/04/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var buttonNext: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonAddTag: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allWords: NSMutableDictionary!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        allWords = NSMutableDictionary()
        
        collectionView.allowsMultipleSelection = true
        
        var nib = UINib(nibName: "TagViewCell", bundle:nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "TagCell");

        self.getScores(){(completion) -> () in
            if(completion == nil){
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allWords.allKeys.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let textSize = (allWords.allKeys[indexPath.row] as! String).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0)]) as CGSize
        //dando um paddingzinho
        
        var tagSize = CGSize()
        
        tagSize.width = textSize.width + 20
        tagSize.height = textSize.height + 8
        
        return tagSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagViewCell
        
        cell.tagName.text = allWords.allKeys[indexPath.row] as! String
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
        
    }

    
    @IBAction func textChanged(_ sender: Any) {
    }
    
    
    
    @IBAction func addTag(_ sender: Any) {
        
        
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var cell = collectionView.cellForItem(at: indexPath) as! TagViewCell
        
        cell.isMarked = true
        cell.contentView.backgroundColor = UIColor(red: 0.1, green: 0.7, blue: 0.7, alpha: 1)
        
        if((collectionView.indexPathsForSelectedItems?.count)! >= 10){
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        var cell = collectionView.cellForItem(at: indexPath) as! TagViewCell
        
        cell.isMarked = false
        cell.contentView.backgroundColor = UIColor(red: 0.31, green: 0.87, blue: 0.87, alpha: 1)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "searchToResult", sender: self)
    }
    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let searchResultController = segue.destination as! SearchResultController
        
        var query = NSMutableArray()
        
        for ip in collectionView.indexPathsForSelectedItems!{
            query.add(allWords.allKeys[ip.row])
        }
        
        searchResultController.allWords = self.allWords
        searchResultController.queryTags = query
    }
 

}
