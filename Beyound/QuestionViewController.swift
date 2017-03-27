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
    
    var totalGrades : Int!
    
    var tagsGrades = [Int]()
    var tags = [String]()
    var totalQuestions :Int = 10
    var weight : Int!
    
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
        tags = allTags.value(forKey: String(page)) as! [String]

        ///Notas das tags
        let allTagsGrades = ["1": [5, 4, 3], "2": [3, 4, 5], "3": [1, 1, 1], "4": [3, 4, 5], "5": [5, 5, 5], "6": [1, 2, 4], "7": [5, 4, 3], "8": [5, 4, 4], "9": [4, 5, 4], "10": [4, 5, 6]] as NSDictionary
        tagsGrades = allTagsGrades.value(forKey: String(page)) as! [Int]

        //pesos das perguntas
        let allWeights = [10, 5, 5, 10, 4, 3, 5, 10, 5, 3] as [Int]
        //peso da pergunta atual
        weight = allWeights[page-1]
        
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
        let wordTags = NSMutableArray()
        
        if((indexPaths?.count)! > 0){
            //calcula a primeira parte da equação, soma das medias dos resultados da pergunta de acordo com as notas das tags
            var sum = 0
            var avg = 0
            
            for item in indexPaths! {
                sum += tagsGrades[item.row]
                wordTags.add(tags[item.row])
            }
            
            avg = sum / indexPaths!.count
            //multiplica a média das respostas das tags pelo peso da pergunta
            avg *= weight
            
            var questionaryResult = Singleton.sharedInstance.getQuestionaryResult() as NSMutableDictionary
            questionaryResult.setValue(wordTags, forKey: String(page!))
            
            if(page == totalQuestions){
                
                self.totalGrades! += avg
                performSegue(withIdentifier: "questionToProfile", sender: self)
                
            }else{
                
                let nextQuestion = self.storyboard?.instantiateViewController(withIdentifier: "questionController") as! QuestionViewController
                
                nextQuestion.page = self.page+1
                nextQuestion.totalGrades = self.totalGrades + avg
                self.navigationController?.pushViewController(nextQuestion, animated: true)
                
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "questionToProfile"){
            
            let influenciadorViewController = segue.destination as! IndexInfluenciadorViewController
            influenciadorViewController.didCameFromQuestionary = true
            influenciadorViewController.questionGrade = totalGrades
        }
        
    }
        
}
