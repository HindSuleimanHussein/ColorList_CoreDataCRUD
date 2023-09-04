//
//  NewColorViewController.swift
//  ColorsTask
//
//  Created by Foothill on 18/09/2023.
//

import UIKit

protocol NewColorViewControllerDelegate: AnyObject {
    func newColorViewController(_ viewController: NewColorViewController, didAddNewColor color: ColorModel)
}

class NewColorViewController: UIViewController {
    
    @IBOutlet weak var colorTitleTextField: UITextField!
    @IBOutlet weak var choosingColorButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addColorButton: UIButton!
    
    var colorsViewController: ColorsViewController?
    weak var delegate: NewColorViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorTitleTextField()
        configureChoosingColorButton()
        configureDescriptionTextView()
        configureAddColorButton()
        tapChoosingColorButton()

    }
    
    func configureColorTitleTextField(){
        colorTitleTextField.layer.cornerRadius = 20
        colorTitleTextField.layer.borderWidth = 1
        colorTitleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: colorTitleTextField.frame.height))
        colorTitleTextField.leftView = paddingView
        colorTitleTextField.leftViewMode = .always
        
        
    }
    
    func configureChoosingColorButton(){
        choosingColorButton.layer.cornerRadius = 15
        choosingColorButton.layer.masksToBounds = true
    }
    
    func configureDescriptionTextView(){
        descriptionTextView.layer.cornerRadius = 20
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 0, right: 10.0)
       
    }
    
    func configureAddColorButton(){
        addColorButton.layer.cornerRadius = 15
        addColorButton.layer.masksToBounds = true
    }
    
    func tapChoosingColorButton(){
        choosingColorButton.addTarget(self, action: #selector(didTapSelectColor), for: .touchUpInside)
    }
    
    @objc private func didTapSelectColor(){
        let colorPickerViewController = UIColorPickerViewController()
        colorPickerViewController.delegate = self
        present(colorPickerViewController, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        guard let text = colorTitleTextField?.text,
                  let tintColor = choosingColorButton?.tintColor,
                  let descriptionText = descriptionTextView?.text else {
                return
            }
            
            let hexToString = hexString(from: tintColor)
            
            let newColor = ColorModel(colorValue: hexToString, name: text, description: descriptionText, id: text)
            delegate?.newColorViewController(self, didAddNewColor: newColor)
            
        if let colorsViewController = colorsViewController {
                print("Navigating back to ColorsViewController")
                navigationController?.popToViewController(colorsViewController, animated: true)
            } else {
                print("colorsViewController is nil")
            }
            
                
    }
    
    func hexString(from color: UIColor) -> String {
        guard let components = color.cgColor.components else {
            return "000000"
        }
        
        let red = UInt8(components[0] * 255.0)
        let green = UInt8(components[1] * 255.0)
        let blue = UInt8(components[2] * 255.0)
        
        return String(format: "%02X%02X%02X", red, green, blue)
    }




}

extension NewColorViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) { //the function is called everytime a color is picked
        let color = viewController.selectedColor
        choosingColorButton.tintColor = color
    }
    
}
