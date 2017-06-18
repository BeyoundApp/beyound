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
    
    var userLoggedId : String
    var userLoggedName : String
    var userLoggedEmail : String
    var userLoggedCnpj : String

    init() {
        self.influenciador = NSDictionary()
        self.questionaryResult = NSMutableDictionary()
        self.userLoggedId = String()
        self.userLoggedName = String()
        self.userLoggedEmail = String()
        self.userLoggedCnpj = String()
    }
    
    func setUserLoggedName(name :String){
        self.userLoggedName = name
    }
    
    func getUserLoggedName() -> String{
        return self.userLoggedName
    }

    func setUserLoggedEmail(email :String){
        self.userLoggedEmail = email
    }
    
    func getUserLoggedEmail() -> String{
        return self.userLoggedEmail
    }

    func setUserLoggedCnpj(cnpj :String){
        self.userLoggedCnpj = cnpj
    }
    
    func getUserLoggedCnpj() -> String{
        return self.userLoggedCnpj
    }

    
    func setUserLoggedId(id :String){
        self.userLoggedId = id
    }
    
    func getUserLoggedId() -> String{
        return self.userLoggedId
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
