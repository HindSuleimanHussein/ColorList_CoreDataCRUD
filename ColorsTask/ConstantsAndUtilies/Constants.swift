//
//  ViewController.swift
//  ColorsTask
//
//  Created by Foothill on 19/09/2023.
//

import UIKit

class Constants: UIViewController {
    
    struct Conts { // put it in its own file
        
        struct userDefaults {
            static let userDefaultsKey = "ReorderedColors"
        }
        
        struct editButtonText {
            static let doneText = "Done"
            static let editText = "Edit"
        }
        
        struct identifiersForSegue {
            static let toNewColorViewController = "toNewColorViewController"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    
}
