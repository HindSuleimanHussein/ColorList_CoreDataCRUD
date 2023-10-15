//
//  ColorTableViewCell.swift
//  ColorsTask
//
//  Created by Foothill on 31/08/2023.
//

import UIKit

class ColorTableViewCell: UITableViewCell {
    
    static let colorTableViewCell = "ColorTableViewCell"
    @IBOutlet var myLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    
    var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCellForEditing(isEditing: Bool, isSelected: Bool) {
        if isEditing {
            // Check if the cell is selected and set the image accordingly
            myImage.image = isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        } else {
            // Configure the cell differently when not editing
            // For example, you can set the image to a default state
            myImage.image = UIImage(systemName: "circle")
        }
    }
    
}
