//
//  PauseViewController.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/6/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController{
    
    @IBOutlet var resumeOrNextLevelButton: UIButton!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var mainMenuButton: UIButton!
    @IBOutlet var menuLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //initial view setup
        view.layer.cornerRadius = 35
        view.alpha = 1
        
        resumeOrNextLevelButton.isEnabled = true
        mainMenuButton.isEnabled = true
        retryButton.isEnabled = true
        
        
        resumeOrNextLevelButton.layer.cornerRadius = 5
        retryButton.layer.cornerRadius = 5
        mainMenuButton.layer.cornerRadius = 5
        view.layer.zPosition = 5;
        
        
    }
    
    func setVisible(visible: Bool){
        if(visible){
            view.alpha = 0.7
        }
        else{
            view.alpha = 0
        }
    }
    
    func nextLevel(){
        if(resumeOrNextLevelButton.title(for: UIControl.State.normal) == "Next"){
            print("move on to next level")
            
        }
    }
    
    @IBAction func nextOrRestartClick(){
        if(resumeOrNextLevelButton.title(for: UIControl.State.normal) == "Next"){
            print("clicked on next button")
            
        }else if(resumeOrNextLevelButton.title(for: UIControl.State.normal) == "Resume"){
            print("clicked on resume button")
        
        }
        print("click")
        
        
    }
    
}
