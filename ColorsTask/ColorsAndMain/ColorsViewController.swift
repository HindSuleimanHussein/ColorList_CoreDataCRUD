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
    @IBOutlet weak var deleteButton: UIButton!
    
    var colors: [ColorModel] = []
    var isEditingMode = false
    var selectedIndexPaths: [IndexPath] = []

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
        tableView.register(nib, forCellReuseIdentifier: ColorTableViewCell.colorTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true // Enable cell selection during editing
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
        let context = CoreDataStack.shared.viewContext
        context.perform {
            for (index, color) in self.colors.enumerated() {
                if let colorList = ColorList.findColorList(withID: color.id, inContext: context) {
                    colorList.order = Int16(index)
                }
            }
            
            do {
                try context.save()
            } catch {
                print("Error saving reordered colors: \(error)")
            }
        }
    }
    
    func loadReorderedColors() {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<ColorList> = ColorList.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let reorderedColors = try context.fetch(fetchRequest)
            
            // Clear the existing colors array
            colors.removeAll()
            
            // Convert the fetched Core Data objects to ColorModel objects
            let colorModels = reorderedColors.map { coreDataColor -> ColorModel in
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
            print("Error fetching reordered colors: \(error)")
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditingMode.toggle()
        
        if isEditingMode {
            editBarButton.title = Constants.Conts.editButtonText.doneText
            tableView.isEditing = true
    
        } else {
            editBarButton.title = Constants.Conts.editButtonText.editText
            tableView.isEditing = false
            
            selectedIndexPaths.removeAll()
            print(selectedIndexPaths)
            
        }
        
        // Reload the table view to apply changes to cell images
        tableView.reloadData()
        
    }
    
    
    @IBAction func trashColor(_ sender: Any) {
        // Ensure you are in editing mode and there are selected index paths
            guard isEditingMode, !selectedIndexPaths.isEmpty else {
                return
            }

            // Get the index paths to delete
            let indexesToDelete = selectedIndexPaths

            // Update Core Data
            let context = CoreDataStack.shared.viewContext
            context.perform {
                for indexPath in indexesToDelete {
                    let colorToDelete = self.colors[indexPath.row]
                    if let colorList = ColorList.findColorList(withID: colorToDelete.id, inContext: context) {
                        context.delete(colorList)
                    }
                }

                do {
                    try context.save()
                } catch {
                    print("Error deleting colors: \(error)")
                }

                // Update the colors array
                self.colors = self.colors.enumerated()
                    .filter { index, _ in !indexesToDelete.contains { $0.row == index } }
                    .map { _, color in color }

                // Clear the selectedIndexPaths
                self.selectedIndexPaths.removeAll()

                // Reload the table view
                self.tableView.reloadData()
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
            // Clear the existing colors array
            colors.removeAll()
            
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
        cell.myImage.isHidden = !isEditingMode

        
        // Configure the cell for editing mode and selection
        cell.configureCellForEditing(isEditing: isEditingMode, isSelected: selectedIndexPaths.contains(indexPath))
        
        
        
        return cell
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            // Toggle the selection state
            if let index = selectedIndexPaths.firstIndex(of: indexPath) {
                selectedIndexPaths.remove(at: index)
            } else {
                selectedIndexPaths.append(indexPath)
            }
            
            // Reload the selected cell to update the image
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            
            let selectedColor = colors[indexPath.row]
            ViewColor.backgroundColor = selectedColor.getUIColor()
            
            let description = selectedColor.description
            descriptionTextView.text = description
            
        }
    }

    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ColorTableViewCell
        cell.isChecked = false
        cell.myImage.image = UIImage(systemName: "circle")
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

extension ColorList {
    static func findColorList(withID id: String, inContext context: NSManagedObjectContext) -> ColorList? {
        let fetchRequest: NSFetchRequest<ColorList> = ColorList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching ColorList: \(error)")
            return nil
        }
    }
}



