//
//  ScoreViewController.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/11/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit
import SQLite3


class ScoreViewController: UITableViewController{
    
    //2 dimentional array to hold username and score
    var users: [String] = []
    var scores: [String] = []
    var index: Int = 0
    var tableCalls: Int = 0
    
    //database pointers
    var db:OpaquePointer? = nil
    var statement: OpaquePointer?
    
    //finalDatabaseURL is used to reference db
    var finalDatabaseUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the height of the status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        //get users local device file path url
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return
        }
        
        //this will be db url for accessing dictionary database
        finalDatabaseUrl = documentsUrl.first!.appendingPathComponent("finalDictionary.db")
        
        //print("viwewDidload")
        
        
        // open database
        if sqlite3_open(finalDatabaseUrl.path, &db) != SQLITE_OK {
            //debugLabel.text = "error opening db"
        }
        else{
            //debugLabel.text = "db open"
        }
        
        index = 0
        
    }
    
    @IBAction func backToMain(){
        sqlite3_close(db)
        self.performSegue(withIdentifier: "backMainSegue", sender: self)
    }
    
    
    
    func findUserScoresInDB(){
        
            //print("trying to query after viewDidLoad")
        
            var queryStatement = ""
            
            queryStatement = "SELECT * FROM userScore ORDER BY score DESC;"
            
            self.statement = nil
            
            if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement,nil) == SQLITE_OK){
                while(sqlite3_step(self.statement) == SQLITE_ROW){
                    
                    let user = sqlite3_column_text(self.statement,0)
                    let score = sqlite3_column_int(self.statement,1)
    
                    let userFound = String(cString: user!)
                    let scoreFound = Int(score)
                    
                   
                    
                    users.append(userFound)
                    scores.append(String(scoreFound))
                    
                }
            }
        
        sqlite3_finalize(self.statement)
        
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        //query scores database and retrieve all rows and set to row count for table
        //return queryRows.count
        if(tableCalls > 0 ){
            
        }
        else{
            findUserScoresInDB()
            tableCalls += 1
            //print(users.count)
            
        }
        
        return users.count
    }
    
    

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an instance of UITableViewCell, with default appearance
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        //print("cellforrowat")
        cell.textLabel?.text = users[index]
        cell.detailTextLabel?.text = scores[index]
        
        index += 1
        return cell
    }
    
}
