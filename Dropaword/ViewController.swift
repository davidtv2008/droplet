//
//  ViewController.swift
//  FallingLetters
//
//  Created by Blanca Gutierrez on 2/22/19.
//  Copyright © 2019 SchoolProjects. All rights reserved.
//

import UIKit
import SQLite3
import AVFoundation



class ViewController: UIViewController {
    
    //create my 3 label outlets
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var scoreHeader: UILabel!
    @IBOutlet var wordsLabel: UILabel!
    @IBOutlet var wordsHeader: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var levelHeader: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var delButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var background: UIImageView!
    
    //pause menu setups
    @IBOutlet var pauseMenuLabel: UILabel!
    @IBOutlet var resumeNextButton: UIButton!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var mainMenuButton: UIButton!
    
    
    var completed = false
    
    //variable for playing sound effect
    var audioPlayer = AVAudioPlayer()
    var audioPlayer2 = AVAudioPlayer()
    var audioPlayer3 = AVAudioPlayer()
    
    

    //get the screen height to use to know when to delete buttons
    var screenSize = UIScreen.main.bounds
    var screenHeight: CGFloat = 0
    var screenWidth: CGFloat = 0
    var buttonSize: CGFloat = 0
    
    //wildCard letter color iterator
    var colorChange: Int = 0
    
    //database pointers
    var db:OpaquePointer? = nil
    var db2: OpaquePointer? = nil
    var statement: OpaquePointer?
    var statement2: OpaquePointer?
    var statement3: OpaquePointer?
    
    var dropTimer: Timer!
    var pause: Bool = false
    var adjustScores: Bool = false
    
    //store previouly failed word lookup to not query db again
    var prevBadWords: [String] = []
    var prevGoodWords: [String] = []
    var queryWordFound: String!
    
    //dictionary db file location
    let databaseInMainBundleURL = Bundle.main.url(forResource: "Stats", withExtension: "db")!
    let databaseInMainBundleURL2 = Bundle.main.url(forResource: "Dictionary", withExtension: "db")!
    
    //finalDatabaseURL is used to reference db
    var finalDatabaseUrl: URL!
    var finalDatabaseUrl2: URL!
    
    //to store score, words, level, initialize to 0
    var score: Int = 0
    var words: Int = 0
    
    var myButtons: [UIButton] = []
    
    //fontSize based on screenHeight
    var fontSize = 0
    
    var userName: String = ""
    var prevHighScore: Int32 = 0
    
    //create user and my Letters object
    let letters = Letters()
    let player = Player()
    let level = Level()
    
    //get the number of letters that should appear per level
    var lettersPerLevel = 0
    
    //viewDidLoad is automatically executed on first run
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(userName == ""){
            userName = "quickPlay"
        }
        if(userName == " "){
            userName = "quickPlay"
        }
        
        
        let soundTap = Bundle.main.path(forResource: "tapSound", ofType: "mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundTap!))
        }
        catch{
            print(error)
        }
        
        let soundCorrect = Bundle.main.path(forResource: "correctSound", ofType: "mp3")
        
        do{
            audioPlayer2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundCorrect!))
        }
        catch{
            print(error)
        }
        
        let wrongCorrect = Bundle.main.path(forResource: "wrongSound", ofType: "mp3")
        
        do{
            audioPlayer3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: wrongCorrect!))
        }
        catch{
            print(error)
        }
        
        //print("username is \(userName)")
        
        //print("username after trim\(userName)")
        
        //when first launched, query username in db to see if it exists
        //if not in db, create a new record, score will be updated after each level is
        //completed, along with words found
    
        //adjust buttons based on screen orientation on initial startup
        if UIDevice.current.orientation.isLandscape {
            screenSize = UIScreen.main.bounds
            screenWidth = screenSize.width
            screenHeight = screenSize.height
        } else {
            screenSize = UIScreen.main.bounds
            screenWidth = screenSize.width
            screenHeight = screenSize.height
        }
        
        fontSize = Int(screenHeight / 35)
        okButton.layer.cornerRadius = 5
        okButton.layer.zPosition = 1
        okButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        delButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        menuButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        resumeNextButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        retryButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        mainMenuButton.titleLabel!.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        scoreLabel.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        scoreHeader.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        wordsLabel.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        wordsHeader.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        levelLabel.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        levelHeader.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        wordLabel.font = UIFont(name: "ArialHebrew-Bold", size: CGFloat(fontSize + 10))
        debugLabel.font = UIFont(name: "ArialHebrew-Light", size: CGFloat(fontSize))
        goalLabel.font = UIFont(name: "ArialHebrew-Bold", size: CGFloat(fontSize))
        pauseMenuLabel.font = UIFont(name: "ArialHebrew-Bold", size: CGFloat(fontSize))
        
        delButton.layer.cornerRadius = 5
        delButton.layer.zPosition = 1
        menuButton.layer.cornerRadius = 5
        menuButton.layer.zPosition = 1
        wordLabel.layer.cornerRadius = 5
    
        //hide pausemenu on init startup
        pauseMenuLabel.alpha = 0
        resumeNextButton.alpha = 0
        resumeNextButton.layer.cornerRadius = 5
        retryButton.alpha = 0
        retryButton.layer.cornerRadius = 5
        mainMenuButton.alpha = 0
        mainMenuButton.layer.cornerRadius = 5
        
        let size = CGFloat(Int(self.screenWidth  / 6))
        
        lettersPerLevel = level.letterPerLevel[level.level-1]
        
        let sizeInt = Int(size)
        
        let randx = CGFloat.random(in: 0 ..< screenWidth - size)
        
        if(screenWidth < screenHeight){
            buttonSize = CGFloat(Int(self.screenWidth) / 6)
        }
        else{
            buttonSize = CGFloat(Int(self.screenHeight) / 6)
        }
        
        let firstButton = UIButton()
        firstButton.setTitle(letters.getRandomLetter(), for: .normal)
        firstButton.setTitleColor(UIColor.white, for: .normal)
        firstButton.backgroundColor = UIColor.blue
        //firstButton.backgroundColor = UIColor.
        
        firstButton.layer.cornerRadius = CGFloat(Int(buttonSize / 2))
        firstButton.titleLabel!.font = UIFont(name: "ArialHebrew-Bold", size: CGFloat(fontSize))
        
        firstButton.frame = CGRect(x: randx, y: -CGFloat(sizeInt), width: buttonSize, height: buttonSize)
        
        firstButton.addTarget(self, action: #selector(formWord(_:)), for: .touchUpInside)
        
        myButtons.append(firstButton)
        
        view.addSubview(firstButton)
 
        //display initial labels with 0 values
        scoreLabel.text = String(score)
        wordsLabel.text = String(words)
        wordsLabel.layer.zPosition = -2
        background.layer.zPosition = -3
        wordLabel.layer.zPosition = 1
        levelLabel.text = String(level.level)
        goalLabel.text = String(level.getGoal())
        goalLabel.layer.zPosition = -1
        okButton.layer.zPosition = 1
        
        copyDatabaseIfNeeded("Stats")
        copyDatabaseIfNeeded("Dictionary")
        
        // open database
        if sqlite3_open(finalDatabaseUrl.path, &db) != SQLITE_OK {
            //debugLabel.text = "error opening db"
        }
        else{
            //debugLabel.text = "db open"
        }
        
        if sqlite3_open(finalDatabaseUrl2.path, &db2) != SQLITE_OK {
            //debugLabel.text = "error opening db"
        }
        else{
            //debugLabel.text = "db open"
        }
        
        insertUserInDB()
        
        dropTimer = Timer.scheduledTimer(timeInterval: TimeInterval(level.dropSpeed[level.level - 1]), target: self, selector: #selector(dropButton), userInfo: nil, repeats: true)
    }
    
    func insertUserInDB(){
        
            var queryStatement = ""
            
            queryStatement = "SELECT * FROM userScore WHERE username = ?;"
        
            self.statement2 = nil
        
            if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement2,nil) == SQLITE_OK)
            {
                //print("SQLITE OK checking username")
                sqlite3_bind_text(self.statement2,1,userName,-1,nil)
                
                if(sqlite3_step(self.statement2) == SQLITE_ROW){
                    //print("select user from db to see if it exists")
                    
                    let score = sqlite3_column_int(self.statement2,1)
                    self.prevHighScore = score
                    //print("prev high score: \(self.prevHighScore)")
                    //sqlite3_finalize(self.statement)
                }else{
                    //print("user not exists, enter into db")
                    
                    sqlite3_reset(self.statement2)
                    sqlite3_finalize(self.statement2)
                    
                    //print("NO RETURNED RESULTS username")
                    
                    var queryStatement = ""
                    
                    //since user is not in db, add it to db
                    queryStatement = "INSERT INTO userScore(username,score) VALUES(?,0);"
                    
                    self.statement2 = nil
                    
                    if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement2,nil) == SQLITE_OK){
                        //print("SQLITE OK INSERTING username")
                        sqlite3_bind_text(self.statement2,1,userName,-1,nil)
                        
                        if(sqlite3_step(self.statement2) == SQLITE_DONE){
                            //print("sqlite done inserting username")
                            //sqlite3_finalize(self.statement)
                        }
                        else{
                            //print("Trouble inserting user")
                            //sqlite3_finalize(self.statement)
                        }
                        sqlite3_reset(self.statement2)

                    }
                    //sqlite3_finalize(self.statement)
                }
                //sqlite3_finalize(self.statement)
        }
        sqlite3_finalize(self.statement2)
    }
    
    //handle the screenrotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            screenSize = UIScreen.main.bounds
            screenHeight = screenSize.width
            screenWidth = screenSize.height
            
            if (screenWidth < screenHeight){
                screenWidth = screenSize.width
                screenHeight = screenSize.height
                
            }
        } else {
            screenSize = UIScreen.main.bounds
            screenHeight = screenSize.width
            screenWidth = screenSize.height
            
            if (screenWidth > screenHeight){
                screenWidth = screenSize.width
                screenHeight = screenSize.height
            }
        }
    }
    
    @IBAction func mainMenu(){
        
        //close database if moving to another view
        sqlite3_close(db)
        sqlite3_close(db2)
        
        //switch to main menu view
        performSegue(withIdentifier: "mainMenuSegue", sender: nil)

    }
    
    //initialize next level
    func prepareNextLevelButtons(){
        
        //remove all letters from array and view
        //and reinitialize new buttons for game restart
        var c = 0
        while ( c < myButtons.count){
            myButtons[c].removeFromSuperview()
            c += 1
        }
        
        myButtons.removeAll()
        
        //initialize first letter to be loaded
        myButtons.append(makeButtonWithText(text: letters.getRandomLetter()))
        myButtons[0].layer.zPosition = 0
        myButtons[0].alpha = 1
        view.addSubview(myButtons[0])
        
        wordsLabel.text = String("0")
        wordLabel.text = String("")
        okButton.isEnabled = true
        delButton.isEnabled = true
        
        lettersPerLevel = level.letterPerLevel[level.level-1]
        dropTimer = Timer.scheduledTimer(timeInterval: TimeInterval(level.dropSpeed[level.level - 1]), target: self, selector: #selector(dropButton), userInfo: nil, repeats: true)
    }

    func stopTimer(){
        dropTimer.invalidate()
    }
    
    @IBAction func pauseMenu(){
        if(pause){
            
            var c = 0
            while(c < myButtons.count){
                myButtons[c].alpha = 1
                c += 1
            }
            
            pause = false
            
            //restart the timer
            dropTimer = Timer.scheduledTimer(timeInterval: TimeInterval(level.dropSpeed[level.level - 1]), target: self, selector: #selector(dropButton), userInfo: nil, repeats: true)
            
            okButton.isEnabled = true
            delButton.isEnabled = true
            
            //hide pausemenu on init startup
            pauseMenuLabel.alpha = 0
            resumeNextButton.alpha = 0
            retryButton.alpha = 0
            mainMenuButton.alpha = 0
        }
        else{
            //stop the timer, set all buttons invisible
            dropTimer.invalidate()
            var c = 0
            while(c < myButtons.count){
                myButtons[c].alpha = 0
                c += 1
            }
            
            pause = true
            
            okButton.isEnabled = false
            delButton.isEnabled = false
            //hide pausemenu on init startup
            pauseMenuLabel.alpha = 0.8
            resumeNextButton.alpha = 0.8
            retryButton.alpha = 0.8
            mainMenuButton.alpha = 0.8
        }
    }
    
    @objc func dropButton()
    {
        var c = 0
        if (lettersPerLevel != 0){
            while(c < myButtons.count){
                myButtons[c].frame.origin.y += 1
                
                //change the colors of the wildcard letter
                if(myButtons[c].title(for: UIControl.State.normal) == "_"){
                    if(colorChange == 0){
                        myButtons[c].backgroundColor = UIColor.blue
                        colorChange += 1
                        
                    }
                    else if(colorChange == 1){
                        myButtons[c].backgroundColor = UIColor.red
                        colorChange += 1
                        
                    }
                    else if(colorChange == 2){
                        myButtons[c].backgroundColor = UIColor.black
                        colorChange += 1
                        
                    }
                    else if(colorChange == 3){
                        myButtons[c].backgroundColor = UIColor.white
                        colorChange += 1
                        
                    }
                    else if(colorChange == 4){
                        myButtons[c].backgroundColor = UIColor.yellow
                        colorChange += 1
                        
                    }
                    else if(colorChange == 5){
                        myButtons[c].backgroundColor = UIColor.cyan
                        colorChange += 1
                        
                    }
                    else if(colorChange == 6){
                        myButtons[c].backgroundColor = UIColor.brown
                        colorChange += 1
                        
                    }
                    else if(colorChange == 7){
                        myButtons[c].backgroundColor = UIColor.magenta
                        colorChange += 1
                    }
                    else if(colorChange == 8){
                        myButtons[c].backgroundColor = UIColor.green
                        colorChange = 0
                    }
                }
                
                //make buttons disabled once they touch back of button
                let borderLimit = okButton.frame.maxY
                if(myButtons[c].frame.maxY > borderLimit){
                    myButtons[c].isEnabled = false
                }

                if(myButtons[c].frame.origin.y == 0){
                    
                    let newButton = makeButtonWithText(text: letters.getRandomLetter())
                    
                    myButtons.append(newButton)
                    view.addSubview(newButton)
                    //print(myButtons.count)
                    
                }else if (myButtons[c].frame.origin.y > screenHeight){
                    myButtons[c].removeFromSuperview()
                    myButtons.remove(at: c)
                }
                c += 1
            }
        }
        else{
            c = 0
            while(c < myButtons.count){
                myButtons[c].frame.origin.y += 1
                
                //change the colors of the wildcard letter
                if(myButtons[c].title(for: UIControl.State.normal) == "_"){
                    if(colorChange == 0){
                        myButtons[c].backgroundColor = UIColor.blue
                        colorChange += 1
                        
                    }
                    else if(colorChange == 1){
                        myButtons[c].backgroundColor = UIColor.red
                        colorChange += 1
                        
                    }
                    else if(colorChange == 2){
                        myButtons[c].backgroundColor = UIColor.black
                        colorChange += 1
                        
                    }
                    else if(colorChange == 3){
                        myButtons[c].backgroundColor = UIColor.white
                        colorChange += 1
                        
                    }
                    else if(colorChange == 4){
                        myButtons[c].backgroundColor = UIColor.yellow
                        colorChange += 1
                        
                    }
                    else if(colorChange == 5){
                        myButtons[c].backgroundColor = UIColor.cyan
                        colorChange += 1
                        
                    }
                    else if(colorChange == 6){
                        myButtons[c].backgroundColor = UIColor.brown
                        colorChange += 1
                        
                    }
                    else if(colorChange == 7){
                        myButtons[c].backgroundColor = UIColor.magenta
                        colorChange += 1
                    }
                    else if(colorChange == 8){
                        myButtons[c].backgroundColor = UIColor.green
                        colorChange = 0
                    }
                }
                
                if (myButtons[c].frame.origin.y > screenHeight){
                    myButtons[c].removeFromSuperview()
                    myButtons.remove(at: c)
                }
                c += 1
            }
            
            if(myButtons.count == 0){
                stopTimer()
                
                print("Out of letters")
                pauseMenuLabel.alpha = 0.8
                resumeNextButton.alpha = 0.8
                retryButton.alpha = 0.8
                mainMenuButton.alpha = 0.8
                menuButton.isEnabled = false
                resumeNextButton.isEnabled = false
                words = 0
                wordsLabel.text = String("0")
            }
        }
    }
    
    @objc func formWord(_ sender: UIButton) {
        
        DispatchQueue.global(qos: .unspecified).async{
            self.audioPlayer.play()
        }
        
        
        //DispatchQueue.global(qos: .background).async {
            
        //}
        
        //audioPlayer.play()
        
        let letter = sender.titleLabel!.text
        let appendString = wordLabel.text! + letter!
        
        wordLabel.text = appendString
    
        sender.alpha = 0;
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
        if(database == "Dictionary"){
            finalDatabaseUrl2 = documentsUrl.first!.appendingPathComponent("\(database).db")
            do {
                try fileManager.removeItem(atPath: finalDatabaseUrl2.path)
                //print("DB removed from device")
            } catch let error as NSError {
                print("error removing db from device:\(error.description)")
            }
            
            finalDatabaseUrl2 = documentsUrl.first!.appendingPathComponent("\(database).db")
            
            if !( (try? finalDatabaseUrl2.checkResourceIsReachable()) ?? false) {
                //print("DB does not exist in documents folder")
                //let databaseInMainBundleURL = Bundle.main.resourceURL?.appendingPathComponent("\(database).db")
                
                do {
                    try fileManager.copyItem(atPath: (databaseInMainBundleURL2.path), toPath: finalDatabaseUrl2.path)
                } catch let error as NSError {
                    print("Couldn't copy file to final location! Error:\(error.description)")
                }
                
            } else {
                
            }
            
            
        }
        else if(database == "Stats")
        {
            finalDatabaseUrl = documentsUrl.first!.appendingPathComponent("\(database).db")
            if !( (try? finalDatabaseUrl.checkResourceIsReachable()) ?? false) {
                //print("DB does not exist in documents folder")
                //let databaseInMainBundleURL = Bundle.main.resourceURL?.appendingPathComponent("\(database).db")
                
                do {
                    try fileManager.copyItem(atPath: (databaseInMainBundleURL.path), toPath: finalDatabaseUrl.path)
                } catch let error as NSError {
                    print("Couldn't copy file to final location! Error:\(error.description)")
                }
                
            } else {
                
            }
            
        }
    
        
        
        
    }
    
    func query(word: String) -> Bool{
        
        var foundBad = false
        var foundGood = false
        
        //check if bad or good word has been searched for before, do not query again
        for value in self.prevBadWords {
            if let index = self.prevBadWords.index(of: value) {
                
                if(wordLabel.text! == prevBadWords[index]){
                    foundBad = true
                }
            }
        }
        
        for value in self.prevGoodWords {
            if let index = self.prevGoodWords.index(of: value) {
                
                if(wordLabel.text! == prevGoodWords[index]){
                    foundGood = true
                }
            }
        }
        
        if(wordLabel.text!.count < 2){
            self.okButton.isEnabled = true
            return false
        }
        else if(foundBad == true){
            audioPlayer3.play()
            self.okButton.isEnabled = true
            return false
        }
        else if(foundGood == true){
            //assign point stats
            audioPlayer2.play()
            setScores(wordPassed: word)
            debugLabel.text = word
            self.okButton.isEnabled = true
            return false
        }
        else{
            
            
            //do not update any UI from main thread, app will throw exception
            //create seperate variables, then do anything after the asynchonous background thread finishes
            //sqlite3_finalize(self.statement)
            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")
            
                var queryStatement = ""
                self.statement = nil
                sqlite3_reset(self.statement)

                sqlite3_finalize(self.statement)
            
                self.statement = nil
            
                //allows for use of wild card character
                if word.contains("_"){
                    queryStatement = "SELECT word FROM entries WHERE word like ? COLLATE NOCASE;"
                }
                else{
                    queryStatement = "SELECT word FROM entries WHERE word = ? COLLATE NOCASE;"
                }
                if (sqlite3_prepare_v2(self.db2,queryStatement,-1,&self.statement,nil) == SQLITE_OK){
                    sqlite3_bind_text(self.statement,1,word,-1,nil)
                    if(sqlite3_step(self.statement) == SQLITE_ROW){
                        self.audioPlayer2.play()
                        print("click on queryWord ok butotn")
                        let queryResult = sqlite3_column_text(self.statement,0)
                        let wordFound = String(cString: queryResult!)
                        self.prevGoodWords.append(wordFound)
                        self.adjustScores = true
                        self.queryWordFound = wordFound
                        self.player.allWordsFound.append(wordFound)
                    }else{
                        self.audioPlayer3.play()
                        print("NO RETURNED RESULTS")
                        //self.prevBadWords.append(word)
                    }
                }
                else{
                    print("select could not be prepared")
                }
                DispatchQueue.main.async {
                    print("query thread done")
                    self.okButton.isEnabled = true
                    
                    if(self.adjustScores == true){
                        self.setScores(wordPassed: self.queryWordFound)
                    }
                }
                sqlite3_finalize(self.statement)
            }
        }
        return true
    }
    
    func setScores(wordPassed: String){
        print(wordPassed)
        debugLabel.text = wordPassed
        let wordLength = wordPassed.count
        if (wordLength == 1){
            score += 1
            words += 1
            
        }
        else if(wordLength == 2){
            score += 2
            words += 1
            
        }
        else if(wordLength == 3){
            score += 3
            words += 1
            
        }
        else if(wordLength == 4){
            score += 4
            words += 1
            
        }
        else if(wordLength == 5){
            score += 8
            words += 1
            
        }
        else if(wordLength == 6){
            score += 9
            words += 1
        }
        else if(wordLength == 7){
            score += 10
            words += 1
        }
        else if(wordLength == 8){
            score += 11
            words += 1
        }
        else if(wordLength == 9){
            score += 22
            words += 1
        }
        else if(wordLength == 10){
            score += 23
            words += 1
        }
        else if(wordLength == 11){
            score += 24
            words += 1
        }
        else if(wordLength == 12){
            score += 25
            words += 1
        }
        else if(wordLength == 13){
            score += 50
            words += 1
        }
        else if(wordLength == 14){
            score += 51
            words += 1
        }
        else if(wordLength == 15){
            score += 52
            words += 1
        }
        else if(wordLength == 16){
            score += 53
            words += 1
        }
        else if(wordLength == 17){
            score += 106
            words += 1
        }
        else if(wordLength == 18){
            score += 107
            words += 1
        }
        else if(wordLength == 19){
            score += 108
            words += 1
        }
        else if(wordLength == 20){
            score += 109
            words += 1
        }
        else if(wordLength == 21){
            score += 200
            words += 1
        }
        
        wordsLabel.text = String(words)
        
        //check if level completed
        player.words.append(wordLabel.text!)
        completed = self.level.checkCompletion(words: player.words)
        if (completed){
            print("level completed")
            
            print(score)
            print(self.prevHighScore)
            
            //only update db if previous high score for the username is lower than current score
            if(score > self.prevHighScore){
                //print("score is bigger than prevScore")
            //update db user scores and words after each level is completed
    
                var queryStatement = ""
                queryStatement = "UPDATE userScore SET score = ? WHERE username = ?;"
                self.statement3 = nil
                
                
                if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement3,nil) == SQLITE_OK){
                    //print("SQLITE OK updating score per level")
                    
                    sqlite3_bind_int(self.statement3, 1, Int32(self.score))
                    sqlite3_bind_text(self.statement3,2,self.userName,-1,nil)
                    
                    if(sqlite3_step(self.statement3) == SQLITE_DONE){
                        //print("sqlite done in updating username")
                        
                        //once updating score is done,
                        //remove all words from userWords and current user and then insert all words
                        var queryStatement = ""
                        
                        queryStatement = "delete from userWords where username = ?;"
                        
                        sqlite3_finalize(self.statement3)
                        
                        self.statement3 = nil
                        
                        if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement3,nil) == SQLITE_OK){
                            //print("SQLITE OK deleting all words for user")
                            
                            sqlite3_bind_text(self.statement3,1,self.userName,-1,nil)
                            
                            if(sqlite3_step(self.statement3) == SQLITE_DONE){
                                // print("sqlite done removing all words for user")
                                sqlite3_finalize(self.statement3)
                                
                                //once all prev words removed db, update all words found currently
                                var i = 0
                                while(i < self.player.allWordsFound.count){
                                    var queryStatement = ""
                                    
                                    queryStatement = "INSERT INTO userWords(username,words) VALUES(?,?);"
                                    
                                    self.statement3 = nil
                                    
                                    if (sqlite3_prepare_v2(self.db,queryStatement,-1,&self.statement3,nil) == SQLITE_OK){
                                        //print("SQLITE OK INSERTING WORDS per level")
                                        sqlite3_bind_text(self.statement3,1,self.userName,-1,nil)
                                        sqlite3_bind_text(self.statement3,2,self.player.allWordsFound[i],-1,nil)
                                        
                                        if(sqlite3_step(self.statement3) == SQLITE_DONE){
                                            //print("sqlite done in inserting words into userWords")
                                            sqlite3_finalize(self.statement3)
                                        }
                                        i += 1
                                    }
                                }
                            }else{
                                //print("NO deleting possible")
                            }
                        }
                    }else{
                        //print("NO updating possible")
                    }
                }
            }
            //sqlite3_finalize(self.statement)
            
            player.score = score
            
            player.words.removeAll()
            
            //wordsLabel.text = String("0")
            wordLabel.text = "Level Completed"
            goalLabel.text = "Level Completed"
            menuButton.isEnabled = false
            
            resumeNextButton.alpha = 0.8
            resumeNextButton.setTitle(" Next ", for: .normal)
            
            retryButton.alpha = 0.8
            mainMenuButton.alpha = 0.8
            
            okButton.isEnabled = false
            delButton.isEnabled = false
            
            pause = true
            
            words = 0
            
            var c = 0
            while ( c < myButtons.count){
                myButtons[c].removeFromSuperview()
                c += 1
            }
            
            myButtons.removeAll()
            
            
            stopTimer()
        }
        else{
            
        }
        
        //wordsLabel.text = String(words)
        scoreLabel.text = String(score)
        //levelLabel.text = String(level.level)
        //goalLabel.text = String(level.getGoal())
        wordLabel.text = ""
        
        
    }
    
    func removeLetter(){
        
        //remove 1 letter at a time from word
        let count = wordLabel.text!.count
        if(count > 0){
            wordLabel.text = String(wordLabel.text!.prefix(count - 1))
            
        }
    }
    
    @IBAction func resumeOrNext(){
        if(resumeNextButton.title(for: UIControl.State.normal) == " Resume "){
            if(pause == true){
                pauseMenu()
                pause = false
            }
        }
        else{
            menuButton.isEnabled = true
            
            player.prevScore = player.score
            
            print(player.allWordsFound)
            completed = false
            
            resumeNextButton.alpha = 0
            resumeNextButton.setTitle(" Resume ", for: .normal)
            
            retryButton.alpha = 0
            mainMenuButton.alpha = 0
            
            levelLabel.text = String(level.level)
            goalLabel.text = String(level.getGoal())
            
            //setup next level
            pause = false
            debugLabel.text = ""
            prepareNextLevelButtons()
        }
    }
    
    @IBAction func retry(){
        
        menuButton.isEnabled = true
        resumeNextButton.isEnabled = true
        resumeNextButton.alpha = 0
        resumeNextButton.setTitle(" Resume ", for: .normal)
        retryButton.alpha = 0
        mainMenuButton.alpha = 0
        pauseMenuLabel.alpha = 0
        
        if(completed){
            level.level -= 1
            completed = false
            player.score = player.prevScore
        }
        
        //clear out all player words found
        
        player.words.removeAll()
        
        if(level.level == 1){
            player.score = 0
            score = 0
            words = 0
        }
        else if(level.level > 1){
            player.score = player.prevScore
            score = player.prevScore
            words = 0
        }
        
        scoreLabel.text = String(score)
        
        
        debugLabel.text = ""
        levelLabel.text = String(level.level)
        wordsLabel.text = String("0")
        goalLabel.text = String(level.getGoal())
        pause = false
        
        prepareNextLevelButtons()
    }
    
    @IBAction func queryWord(){
        //everytime query is run, disable button until it finishes
        self.adjustScores = false
        self.okButton.isEnabled = false
        _ = query(word: wordLabel.text!)
        
    }
    
    @IBAction func removeChar(){
        removeLetter()
    }
    
    //use function to make a button with text
    
    func makeButtonWithText(text:String) -> UIButton {
        
        let size = CGFloat(Int(self.screenWidth  / 6))
        //determine how many letters to fill screen, before respawning
        //numberOfLetters = Int((self.screenHeight / size)+1)
        
        //let c = 0
        //let sizeInt = Int(size)
        
        let myButton = UIButton()
        myButton.setTitle(letters.getRandomLetter(), for: .normal)
        myButton.setTitleColor(UIColor.white, for: .normal)
        myButton.backgroundColor = UIColor.blue
        myButton.layer.cornerRadius = CGFloat(Int(buttonSize / 2))
        myButton.titleLabel!.font = UIFont(name: "ArialHebrew-Bold", size: CGFloat(fontSize))
        
        
        let randx = CGFloat.random(in: 0 ..< screenWidth - size)
        
        
        //myButton.frame = CGRect(x: 5, y: -CGFloat(c * sizeInt), width: size, height: size)
        myButton.frame = CGRect(x: randx, y: -size, width: buttonSize, height: buttonSize)
        
        
        myButton.addTarget(self, action: #selector(formWord(_:)), for: .touchUpInside)
        
        lettersPerLevel -= 1
        
        return myButton
    }
}

