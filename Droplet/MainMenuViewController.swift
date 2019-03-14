//
//  MainMenuViewController.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/12/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController{
    @IBOutlet var playButton: UIButton!
    @IBOutlet var scoresButton: UIButton!
    
    //database pointers
    var db:OpaquePointer? = nil
    var statement: OpaquePointer?
    
    //dictionary db file location
    let databaseInMainBundleURL = Bundle.main.url(forResource: "Dictionary", withExtension: "db")!
    
    //finalDatabaseURL is used to reference db
    var finalDatabaseUrl: URL!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = 5
        playButton.alpha = 0.8
        scoresButton.layer.cornerRadius = 5
        scoresButton.alpha = 0.8
        
        copyDatabaseIfNeeded("Dictionary")
        
        
        
        
    }
    
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
    
    func goToScoresView() {
        
        self.performSegue(withIdentifier: "scoresSegue", sender: self)
        
    }
    
}
