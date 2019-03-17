//
//  Letters.swift
//  FallingLetters
//
//  Created by Blanca Gutierrez on 2/22/19.
//  Copyright © 2019 SchoolProjects. All rights reserved.
//

import UIKit

class Letters{
    
    let alphabet = ["E","E","E",
                    "E","E","E",
                    "A","A","A",
                    "A","A","R",
                    "R","R","R",
                    "R","I","I",
                    "I","I","O",
                    "O","O","T",
                    "T","T","N",
                    "N","N","S",
                    "S","L","L",
                    "C","C","U",
                    "U","D","P",
                    "A","B","C",
                    "D","E","F",
                    "G","H","E",
                    "J","K","L",
                    "M","N","O",
                    "P","Q","R",
                    "S","T","U",
                    "V","W","X",
                    "Y","Z","_",
                    "_","_","_",
                    "_","_","_"]
    
    func getRandomLetter()->String{
        
        let index = Int.random(in: 0 ..< alphabet.count - 1)
        
        return alphabet[index]
    }
    
}
