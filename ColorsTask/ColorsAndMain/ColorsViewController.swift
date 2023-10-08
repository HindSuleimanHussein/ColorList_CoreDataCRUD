//  ColorsVC.swift
//  ColorsTask
//
//  Created by Foothill on 13/08/2023.
//

import UIKit
import CoreData

class ColorsViewController: UIViewController {
    
    
    @IBOutlet weak var ViewColor: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    var colors: [ColorModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorTableViewCell()
        configureDescriptionTextView()
        configureNavbarButton()
        fetchSavedColors()
        loadReorderedColors()
     
    }
    
    func addColor(_ color: ColorModel) {
        colors.append(color)
        print("Added color: \(color.name)")
        print("Updated colors array: \(colors)")
    }


    
    func configureColorTableViewCell() {
        let nib = UINib(nibName: ColorTableViewCell.colorTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier:  ColorTableViewCell.colorTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = false
    }
    
    func configureDescriptionTextView() {
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 40.0)
        descriptionTextView.isEditable = false
    }
    
    func configureNavbarButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        let clearImage = UIImage()
        
        // Set the back indicator image to the clear image
        navigationController?.navigationBar.backIndicatorImage = clearImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = clearImage
        
    }
    
    func getColorsElementID() -> [String] {
        return colors.map { $0.id }
    }
    
    func saveReorderedColors() {
        let orderedColorIDs = getColorsElementID()
        UserDefaultsUtilities.shared.saveReorderedColors(colors: orderedColorIDs)
    }

    
    func loadReorderedColors() {
        if let orderedColorIDs = UserDefaultsUtilities.shared.loadReorderedColors() {
            // Reorder the colors based on the loaded order of IDs
            colors.sort { (color1, color2) -> Bool in
                guard let index1 = orderedColorIDs.firstIndex(of: color1.id),
                      let index2 = orderedColorIDs.firstIndex(of: color2.id) else {
                    return false // Handle missing IDs gracefully
                }
                return index1 < index2
            }
            
            tableView.reloadData()
        }
    }

    
    
    
    
    @IBAction func edit(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        
        switch tableView.isEditing {
        case true:
            editBarButton.title = Constants.Conts.editButtonText.doneText
        case false:
            editBarButton.title = Constants.Conts.editButtonText.editText
        }
        
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.Conts.identifiersForSegue.toNewColorViewController, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Conts.identifiersForSegue.toNewColorViewController {
            if let newColorVC = segue.destination as? NewColorViewController {
                newColorVC.delegate = self
                newColorVC.colorsViewController = self // Set the colorsViewController property
            }
        }
    }
    
    func fetchSavedColors() {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<ColorList> = ColorList.fetchRequest()

        do {
            let savedColors = try context.fetch(fetchRequest)

            // Convert the fetched Core Data objects to ColorModel objects
            let colorModels = savedColors.map { coreDataColor -> ColorModel in
                return ColorModel(
                    colorValue: coreDataColor.colorValue ?? "",
                    name: coreDataColor.name ?? "",
                    description: coreDataColor.descriptionColor ?? "",
                    id: coreDataColor.id ?? ""
                )
            }

            // Assign the fetched colors to your colors array
            colors = colorModels
        } catch {
            print("Error fetching saved colors: \(error)")
        }
    }




}

extension ColorsViewController: NewColorViewControllerDelegate {
    func newColorViewController(_ viewController: NewColorViewController, didAddNewColor color: ColorModel) {
        // Add the new color to your data source
        addColor(color)

        // Reload the table view to reflect the new color
        tableView.reloadData()
        
        // Save the reordered colors
        saveReorderedColors()
    }

}


extension ColorsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ColorTableViewCell.colorTableViewCell, for: indexPath) as! ColorTableViewCell
        
        // Configure the cell based on the color object
        let color = colors[indexPath.row]
        cell.myLabel.text = color.name
        cell.detailTextLabel?.text = color.description
        cell.backgroundColor = color.getUIColor()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected color
        let selectedColor = colors[indexPath.row]
        
        // Update ViewColor with the selected color
        ViewColor.backgroundColor = selectedColor.getUIColor()
        
        // Show the description of the selected color
        let description = selectedColor.description
        descriptionTextView.text = description // Update the label's text
        
        
    }
    
    //Functions that reorder and remove cells
    //Allows reordering of cells
    // Allows reordering of cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Allows cell to be reordered to another place
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedColor = colors.remove(at: sourceIndexPath.row)
        colors.insert(movedColor, at: destinationIndexPath.row)
        
        saveReorderedColors()
    }

    
    // removes the delete button that shows by default
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}



