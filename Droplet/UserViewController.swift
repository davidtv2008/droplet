//
//  UserViewController.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/12/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit
import AVFoundation



class UserViewController: UIViewController{
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var playButton: UIButton!
    
    //variable for playing sound effect
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad(){
        textField.text = ""
        super.viewDidLoad()
        
        let soundTap = Bundle.main.path(forResource: "tapSound", ofType: "mp3")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundTap!))
        }
        catch{
            print(error)
        }
        
        playButton.layer.cornerRadius = 5
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.userName = textField.text!
        }
    }
}
