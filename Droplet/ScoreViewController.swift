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
    
    //database pointers
    var db:OpaquePointer? = nil
    var statement: OpaquePointer?
    
    //dictionary db file location
    let databaseInMainBundleURL = Bundle.main.url(forResource: "Dictionary", withExtension: "db")!
    
    //finalDatabaseURL is used to reference db
    var finalDatabaseUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the height of the status bar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        copyDatabaseIfNeeded("Dictionary")
        
        // open database
        if sqlite3_open(finalDatabaseUrl.path, &db) != SQLITE_OK {
            //debugLabel.text = "error opening db"
        }
        else{
            //debugLabel.text = "db open"
        }
        
        index = 0
        
    }
    
    //check if databae is located in docuements directory, if not copy it over from project bundle
    func copyDatabaseIfNeeded(_ database: String) {
        
        //get users local device file path url
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            return
        }
        
        //this will be db url for accessing dictionary database
        finalDatabaseUrl = documentsUrl.first!.appendingPathComponent("\(database).db")
        
        
        /*
         //remove database file from path, then recopy the bundles version to make it up to date
         do {
         try fileManager.removeItem(atPath: finalDatabaseUrl.path)
         //print("DB removed from device")
         } catch let error as NSError {
         print("error removing db from device:\(error.description)")
         }
         
         finalDatabaseUrl = documentsUrl.first!.appendingPathComponent("\(database).db")
 
        */
        
        print(finalDatabaseUrl)
        
        if !( (try? finalDatabaseUrl.checkResourceIsReachable()) ?? false) {
            //print("DB does not exist in documents folder")
            let databaseInMainBundleURL = Bundle.main.resourceURL?.appendingPathComponent("\(database).db")
            
            do {
                try fileManager.copyItem(atPath: (databaseInMainBundleURL!.path), toPath: finalDatabaseUrl.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            
        } else {
            
        }
    }
    
    func findUserScoresInDB(){
        
            var queryStatement = ""
            
            queryStatement = "SELECT * FROM userScore ORDER BY score DESC;"
            
            self.statement = nil
            
            if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement,nil) == SQLITE_OK){
                //print("SQLITE OK checking username")
                while(sqlite3_step(self.statement) == SQLITE_ROW){
                    print("retrieving rows")
                    
                    let user = sqlite3_column_text(self.statement,1)
                    let score = sqlite3_column_text(self.statement,2)
                    
                    let userFound = String(cString: user!)
                    let scoreFound = String(cString: score!)
                    
                    if (users.contains(userFound)){
                        //users.append(userFound)
                        //print("alread in users")
                    }
                    else{
                        users.append(userFound)
                        scores.append(scoreFound)
                    }
                }
            }
        
        sqlite3_finalize(self.statement)
        
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        //query scores database and retrieve all rows and set to row count for table
        //return queryRows.count
        findUserScoresInDB()
        
        //print(users.count)
        return users.count
    }
    
    

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        // Create an instance of UITableViewCell, with default appearance
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        
        cell.textLabel?.text = users[index]
        cell.detailTextLabel?.text = scores[index]
        
        index += 1
        return cell
    }
    
}
