//  ColorsVC.swift
//  ColorsTask
//
//  Created by Foothill on 13/08/2023.
//

import UIKit

class ColorsViewController: UIViewController {
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var colors: [ColorModel] = []
    private var isEditingMode = false
    private var selectedIndexPaths: [IndexPath] = []

    override func viewDidLoad() {func saveReorderedColors() {
        let context = ColorCoreDataManager.shared.viewContext
        context.perform {
            for (index, color) in self.colors.enumerated() {
                if let colorList = ColorCoreDataManager.shared.findColorList(withID: color.id, inContext: context) {
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
        super.viewDidLoad()
        configureColorTableView()
        configureDescriptionTextView()
        colors = ColorCoreDataManager.shared.loadReorderedColors()
    }

    func configureColorTableView() {
        let nib = UINib(nibName: Constants.TableViewCell.colorTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.TableViewCell.colorTableViewCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true // Enable cell selection during editing
    }

    func configureDescriptionTextView() {
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 20.0, bottom: 0, right: 40.0)
        descriptionTextView.isEditable = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.IdentifiersForSegue.toNewColorViewController {
            if let newColorVC = segue.destination as? NewColorViewController {
                newColorVC.delegate = self
                //newColorVC.colorsViewController = self // Set the colorsViewController property
            }
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        isEditingMode.toggle()
        tableView.isEditing = isEditingMode // TODO: make this into turnary operator if statment
        editBarButton.title = isEditingMode ? Constants.ButtonText.doneText : Constants.ButtonText.editText
        selectedIndexPaths.removeAll()
        // Reload the table view to apply changes to cell images
        tableView.reloadData()
    }
    
    @IBAction func trashColor(_ sender: Any) {
        // Ensure you are in editing mode and there are selected index paths
        guard isEditingMode, !selectedIndexPaths.isEmpty else {
            return
        }
        // Create an array to store the colors to delete
        var colorsToDelete: [ColorModel] = []
        
        for indexPath in selectedIndexPaths { // TODO: ask chatgpt
            let colorToDelete = colors[indexPath.row]
            colorsToDelete.append(colorToDelete)
        }
    
        // Delete the selected colors from Core Data
        for color in colorsToDelete {
            ColorCoreDataManager.shared.deleteColor(color: color)
        }
        // Update the colors array by removing the deleted colors
        for colorDeleted in colorsToDelete {
            for i in 0..<self.colors.count {
                if self.colors[i].id == colorDeleted.id {
                    self.colors.remove(at: i)
                    break
                }
            }
        }
        // Clear the selectedIndexPaths
        self.selectedIndexPaths.removeAll()
        
        // Reload the table view
        self.tableView.reloadData()
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.IdentifiersForSegue.toNewColorViewController, sender: nil)
    }
}

extension ColorsViewController: NewColorViewControllerDelegate {
    func didAddNewColor(color: ColorModel) {
        colors.append(color)
        // Reload the table view to reflect the new color
        tableView.reloadData()
        // Save the reordered colors
        ColorCoreDataManager.shared.saveReorderedColors(colors: colors)
    }
}

extension ColorsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCell.colorTableViewCell, for: indexPath) as! ColorTableViewCell
        
        // Configure the cell based on the color object
        let color = colors[indexPath.row]
        cell.configureCell(color, isEditing: isEditingMode, isSelected: selectedIndexPaths.contains(indexPath))
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
            viewColor.backgroundColor = selectedColor.colorValue
            let description = selectedColor.description
            descriptionTextView.text = description
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ColorTableViewCell
        cell.deselectCell()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Allows cell to be reordered to another place
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedColor = colors.remove(at: sourceIndexPath.row)
        colors.insert(movedColor, at: destinationIndexPath.row)
        ColorCoreDataManager.shared.saveReorderedColors(colors:colors)
    }
    // removes the delete button that shows by default
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}



