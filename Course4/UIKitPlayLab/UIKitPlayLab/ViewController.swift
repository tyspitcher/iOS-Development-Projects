//
//  ViewController.swift
//  UIKitPlayLab
//
//  Created by Tyson Pitcher on 6/3/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var MainViewTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBSegueAction func navigateToCoolDogView(_ coder: NSCoder) -> CoolDogViewController? {
        return CoolDogViewController(coder: coder)
    }
    @IBSegueAction func navigateToSneakyCatView(_ coder: NSCoder) -> SneakyCatViewController? {
        return SneakyCatViewController(coder: coder)
    }
    @IBAction func showCoolDogButton(_ sender: Any) {
        
    }
    
    @IBAction func ShowSneakyCatButton(_ sender: Any) {
        
        
    }
}

