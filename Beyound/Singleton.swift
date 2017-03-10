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
    
    init() {
        self.influenciador = NSDictionary()
    }
    
    func setInfluenciador(influenciador :NSDictionary){
        self.influenciador = influenciador
    }
    
    func getInfluenciador() -> NSDictionary{
        return self.influenciador
    }
    
}
