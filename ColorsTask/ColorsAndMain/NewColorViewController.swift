//
//  NewColorViewController.swift
//  ColorsTask
//
//  Created by Foothill on 18/09/2023.
//

import UIKit

protocol NewColorViewControllerDelegate: AnyObject {
    func didAddNewColor(color: ColorModel)
}

class NewColorViewController: UIViewController {
    @IBOutlet weak var colorTitleTextField: UITextField!
    @IBOutlet weak var choosingColorButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addColorButton: UIButton!
    
    weak var delegate: NewColorViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorTitleTextField()
        configureChoosingColorButton()
        configureDescriptionTextView()
        configureAddColorButton()
        tapChoosingColorButton()
        configureNavbarButton()
    }
    
    func configureColorTitleTextField(){
        colorTitleTextField.layer.cornerRadius = 20
        colorTitleTextField.layer.borderWidth = 1
        colorTitleTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: colorTitleTextField.frame.height)) //TODO: better way
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
    
    func configureNavbarButton() {
        let cancelButton = UIBarButtonItem(title: Constants.ButtonText.barButtonTitle, style: .plain, target: self, action: #selector(closeButtonTapped))
        cancelButton.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
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
            // TODO: alert user alertUI IOS alert
            return
        }
        let newColor = ColorModel(colorValue: tintColor, name: text, description: descriptionText, id: text)
        ColorCoreDataManager.shared.addColor(color: newColor)
        delegate?.didAddNewColor(color: newColor)
        navigationController?.popViewController(animated: true)
    }
}

extension NewColorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) { //the function is called everytime a color is picked
        let color = viewController.selectedColor
        choosingColorButton.tintColor = color
    }
}
