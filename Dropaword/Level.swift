//
//  Level.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/2/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit

class Level{
    
    var level: Int = 1
    
    var letterPerLevel: [Int] = [100,105,110,
                                 115,120,125,
                                 130,135,140,
                                 145,150,155,
                                 150,160,170,2000]
    
    var dropSpeed: [Float] = [0.02,0.019,0.018,
                              0.017,0.016,0.015,
                              0.014,0.013,0.012,
                              0.012,0.012,0.011,
                              0.011,0.011,0.01,
                              0.009]
    
    //11 elements
    var goal: [String] = ["Find 2 Words","Find 3 Words","Find 4 Words",
                          "Find 5 Words","Find 6 Words","Find 7 Words",
                          "Find 8 Words","Find 9 Words","Find 10 Words",
                          "Find 11 Words","Find 12 Words","Find 13 Words",
                          "Find 14 Words","Find 15 Words","Find 16 Words",
                          "Get Highest Score"]
    
    func getGoal()->String{
        return goal[level - 1]
    }
    
    func checkCompletion(words: [String]) -> Bool{
        if (level == 1){
            let wordsFound = words.count
            if (wordsFound == 2){
                level += 1
                return true
            }
        }
        else if(level == 2){
            let wordsFound = words.count
            if (wordsFound == 3){
                level += 1
                return true
            }
        }
        else if(level == 3){
            let wordsFound = words.count
            if (wordsFound == 4){
                level += 1
                return true
            }
        }
        else if(level == 4){
            let wordsFound = words.count
            if(wordsFound == 5){
                level += 1
                return true
            }
        }
        else if(level == 5){
            let wordsFound = words.count
            if(wordsFound == 6){
                level += 1
                return true
            }
        }else if(level == 6){
            let wordsFound = words.count
            if(wordsFound == 7){
                level += 1
                return true
            }
        }else if(level == 7){
            let wordsFound = words.count
            if(wordsFound == 8){
                level += 1
                return true
            }
        }else if(level == 8){
            let wordsFound = words.count
            if(wordsFound == 9){
                level += 1
                return true
            }
        }else if(level == 9){
            let wordsFound = words.count
            if(wordsFound == 10){
                level += 1
                return true
            }
        }else if(level == 10){
            let wordsFound = words.count
            if(wordsFound == 11){
                level += 1
                return true
            }
        }
        else if(level == 11){
            let wordsFound = words.count
            if(wordsFound == 12){
                level += 1
                return true
            }
        }else if(level == 12){
            let wordsFound = words.count
            if(wordsFound == 13){
                level += 1
                return true
            }
        }
        else if(level == 13){
            let wordsFound = words.count
            if(wordsFound == 14){
                level += 1
                return true
            }
        }else if(level == 14){
            let wordsFound = words.count
            if(wordsFound == 15){
                level += 1
                return true
            }
        }else if(level == 15){
            let wordsFound = words.count
            if(wordsFound == 16){
                level += 1
                return true
            }
        }
        
        return false
    }
}
