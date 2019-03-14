//
//  UserViewController.swift
//  Droplet
//
//  Created by Blanca Gutierrez on 3/12/19.
//  Copyright © 2019 Appility. All rights reserved.
//

import UIKit

class UserViewController: UIViewController{
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var playButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
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
