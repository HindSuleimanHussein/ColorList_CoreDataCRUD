//
//  ColorCoreDataManager.swift
//  ColorsTask
//
//  Created by Foothill on 04/10/2023.
//

import CoreData
import UIKit

class ColorCoreDataManager {
    static let shared = ColorCoreDataManager() // singleton class
    
    private init() {// used to initialize properties so that the core data class is instantiated only one and other instances are not created
        let container = NSPersistentContainer(name: Constants.CoreDataModel.colorDataModel)
        container.loadPersistentStores { (storeDescription, error) in
            if let error { // when error is not nil 
                fatalError("Unresolved error \(error.localizedDescription)") // The error will be printed with something understandable
            }
        }
        self.persistentContainer = container
    }
    private let persistentContainer: NSPersistentContainer // only ever used in coredata class
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addColor(color: ColorModel) {
        let context = self.viewContext
        let colorList = ColorList(context: context)
        colorList.name = color.name
        colorList.colorValue = color.colorValue
        colorList.descriptionColor = color.description
        colorList.id = color.id

        do {
            try context.save()
        } catch {
            print("Error adding color to Core Data: \(error)")
        }
    }
    
    func deleteColor(color: ColorModel) {
        let context = self.viewContext
        
        if let colorList = findColorList(withID: color.id, inContext: context) {
            context.delete(colorList)
            
            do {
                try context.save()
            } catch {
                print("Error deleting color from Core Data: \(error)")
            }
        }
    }
    
    func findColorList(withID id: String, inContext context: NSManagedObjectContext) -> ColorList? {
        let fetchRequest: NSFetchRequest<ColorList> = ColorList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: Constants.Formats.findColorIDFormat, id)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching ColorList: \(error)")
            return nil
        }
    }
    
     func saveReorderedColors(colors: [ColorModel]) { //TODO: make non-static
         let context = self.viewContext
        context.perform {
            for (index, color) in colors.enumerated() {
                if let colorList = self.findColorList(withID: color.id, inContext: context) {
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

    func loadReorderedColors() -> [ColorModel] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<ColorList> = ColorList.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: Constants.SortKeys.orderColor, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let reorderedColors = try context.fetch(fetchRequest)

            // Convert the fetched Core Data objects to ColorModel objects
            let colorModels = reorderedColors.map { coreDataColor -> ColorModel in
                let colorValue = coreDataColor.colorValue as? UIColor ?? UIColor.white
                return ColorModel(
                    colorValue: colorValue,
                    name: coreDataColor.name ?? "",
                    description: coreDataColor.descriptionColor ?? "",
                    id: coreDataColor.id ?? ""
                )
            }
            return colorModels
        } catch {
            print("Error fetching reordered colors: \(error)")
            return []
        }
    }

}

