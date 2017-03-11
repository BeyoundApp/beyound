//
//  QuestionViewController.swift
//  Beyound
//
//  Created by Elder Santos on 10/03/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var labelQuestionTitle: UILabel!
    @IBOutlet weak var scrollView: UILabel!
    @IBOutlet weak var pageCounter: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fieldTag: UITextField!

    var page: Int?
    var question : String?
    
    var tags = [String]()
    var totalQuestions :Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "TagViewCell", bundle:nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "TagCell");
        
        self.pageCounter.text = "\(page)/\(totalQuestions)"
        
        tags = ["Prema", "Photography", "Design", "Humor", "Love Traveling", "Music", "Writing", "Easy Life", "Education", "Engineer", "Startup", "Funny", "Women In Tech", "Female", "Business", "Songs", "Love", "Food", "Sports"]

        // Do any additional setup after loading the view.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
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
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagViewCell
        
        if(cell.isMarked!){
            cell.isMarked = false
            cell.backgroundColor = UIColor.blue
            collectionView.deselectItem(at: indexPath, animated: true)
        }else{
            cell.isMarked = true
            cell.backgroundColor = UIColor.green
        }
        
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
