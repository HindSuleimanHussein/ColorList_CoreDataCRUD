//
//  ColorTableViewCell.swift
//  ColorsTask
//
//  Created by Foothill on 31/08/2023.
//

import UIKit

class ColorTableViewCell: UITableViewCell {
    @IBOutlet private var myLabel: UILabel!
    @IBOutlet private weak var myImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(_ color: ColorModel, isEditing: Bool, isSelected: Bool) {
        myLabel.text = color.name
        backgroundColor = color.colorValue
        myImage.isHidden = !isEditing
        
        if isEditing {
            myImage.image = isSelected ? UIImage(systemName: Constants.SystemNameImage.checkmarkCircleImage) : UIImage(systemName: Constants.SystemNameImage.circleImage)
        } else {
            myImage.image = UIImage(systemName: Constants.SystemNameImage.circleImage)
        }
    }
    
    func deselectCell(){
        myImage.image = UIImage(systemName: Constants.SystemNameImage.circleImage)
    }
}
