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
        
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        
        //tags = ["Maquiagem", "Acessórios","Body", "Belo", "Beleza","Fotografia", "Desenho", "Foto",  "Youtuber",  "Expert"]
        
         ///Sequencia das tags
         let allTags = ["1": ["Maquiagem", "Sapatos", "Acessórios"], "2": ["Estiloso", "Feliz", "Rico"], "3": ["Nike", "Globo", "Melissa"], "4": ["Selfie", "Paisagem", "Cotidiano"], "5": ["Homens", "Mulheres", "Entre 15 a 30 anos"], "6": ["100", "1000", "10000"], "7": ["Toda semana", "Quase todo mês", "Raramente"], "8": ["Expert", "Youtuber", "Instagrammer"], "9": ["Merchandising de produtos", "Makes", "Body Builder"], "10": ["Postando frequentemente", "Postando o assunto que eles gostam", "Respondendo eles rapidamente"]] as NSDictionary
        
        ///Sequencia das tags
        let allTagsGrades = ["1": [5, 4, 3], "2": [3, 4, 5], "3": [1, 1, 1], "4": [3, 4, 5], "5": [5, 5, 5], "6": [1, 2, 4], "7": [5, 4, 3], "8": [5, 4, 4], "9": [4, 5, 4], "10": [4, 5, 6]] as NSDictionary

        
        tags = allTags.value(forKey: String(page)) as! [String]
        
        if let url = Bundle.main.url(forResource:"questions", withExtension: "plist") {
            do {
                let data = try Data(contentsOf:url)
                let swiftDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
              
            
                let x : Int = self.page+1
                let myString = String(x)
                        labelQuestionTitle.text = swiftDictionary[myString] as! String?
                    //}
            } catch {
                print(error)
            }
        }
    
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    @IBAction func goToNextQuestion(_ sender: Any) {
        
        let indexPaths = collectionView.indexPathsForSelectedItems
        
        for item in indexPaths! {
            
            print(tags[item.row])
            
        }
        
        //page == totalQuestions
        if(page == 3){
            
            calculateRanking()
            
        }else{
            
            let nextQuestion = self.storyboard?.instantiateViewController(withIdentifier: "questionController") as! QuestionViewController
            
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
        cell.contentView.backgroundColor = UIColor(red: 0.1, green: 0.7, blue: 0.7, alpha: 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        var cell = collectionView.cellForItem(at: indexPath) as! TagViewCell

        cell.isMarked = false
        cell.contentView.backgroundColor = UIColor(red: 0.31, green: 0.87, blue: 0.87, alpha: 1)
        
    }
    
    func calculateRanking(){
        
        let likes = self.calculatePostsLikes()
        
        
    }
    
    func calculatePostsLikes() -> Int{
        
        let influenciador = Singleton.sharedInstance.getInfluenciador() as NSDictionary
        let uid = influenciador.value(forKey: "uid") as! String
        
        let url = "https://tcc-beyound.firebaseio.com/influenciadores/"+uid+"/posts.json?print=pretty"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var err: NSError?
            
            do{
                
                var totalLikes = 0 as Int
                var totalHashTags = 0 as Int

                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
                
                    for item in jsonResult as! [NSDictionary] {
                        
                        //quantidade de likes desse post
                        let count = (item.object(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
                        
                        //quantidade de hashtags do post
                        var numberTags = 0 as Int
                        let tags = (item.object(forKey: "tags") as? NSDictionary)
                        if((tags) != nil){
                            numberTags = (tags?.count)!
                        }
                        
                        totalHashTags += numberTags
                        
                        let caption = item.object(forKey: "caption") as? NSDictionary
                        
                        //verifica se o post tem legenda
                        if((caption) != nil){
                            
                            //palavras da legenda desse post
                            let subtitle = caption?.value(forKey: "text") as! String
                            let components = subtitle.components(separatedBy: CharacterSet.init(charactersIn: " ,.;:"))
                            
                           
                            for var i in (0..<components.count).reversed(){
                                var dictionary = [[String: AnyObject]]()
                                let word = components
                                
                                if word[i].isEmpty == false{
                                    dictionary.append(["nome" : word[i] as AnyObject, "like" : count as AnyObject])
                                }
                            }
                        }
                        
                    }
                }
                
            }catch let error as NSError{
               print(error)
            }
        })
        
        task.resume()
        
        return 0
    }
    
}
