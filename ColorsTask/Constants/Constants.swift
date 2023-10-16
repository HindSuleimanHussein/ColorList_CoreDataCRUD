//
//  ViewController.swift
//  ColorsTask
//
//  Created by Foothill on 19/09/2023.
//

import UIKit

struct Constants {
    struct ButtonText { // capatilize all of these structs
        static let doneText = "Done"
        static let editText = "Edit"
        static let barButtonTitle = "Cancel"
    }
    
    struct TableViewCell {
        static let colorTableViewCell = "ColorTableViewCell"
    }
    
    struct IdentifiersForSegue {
        static let toNewColorViewController = "toNewColorViewController"
    }
    
    struct SystemNameImage {
        static let circleImage = "circle"
        static let checkmarkCircleImage = "checkmark.circle.fill"
    }
    
    struct Formats {
        static let findColorIDFormat = "id == %@"
    }
    
    struct SortKeys {
        static let orderColor = "order"
    }
    
    struct CoreDataModel {
        static let colorDataModel = "MyAppColorDataModel"
    }
}
