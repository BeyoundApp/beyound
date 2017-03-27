//
//  Singeton.swift
//  Beyound
//
//  Created by Elder Santos on 10/03/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import Foundation

class Singleton {
    
    static let sharedInstance = Singleton()
    
    var influenciador : NSDictionary
    var questionaryResult : NSMutableDictionary

    init() {
        self.influenciador = NSDictionary()
        self.questionaryResult = NSMutableDictionary()
    }
    
    func setInfluenciador(influenciador :NSDictionary){
        self.influenciador = influenciador
    }
    
    func getInfluenciador() -> NSDictionary{
        return self.influenciador
    }
    
    func setQuestionaryResult(result :NSMutableDictionary){
        self.questionaryResult = result
    }
    
    func getQuestionaryResult() -> NSMutableDictionary{
        return self.questionaryResult
    }
    
}
