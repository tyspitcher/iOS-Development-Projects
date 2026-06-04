//
//  ViewController.swift
//  InterfaceBuilderBasics
//
//  Created by Tyson Pitcher on 6/2/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mainLabel.text = "I'm learning how to make really awesome apps!"
        
    }
    @IBAction func changeTitle(_ sender: Any) {
        mainLabel.text = "This app rocks!"
    }
    

}

