//
//  ColorList+CoreDataProperties.swift
//  ColorsTask
//
//  Created by Foothill on 25/10/2023.
//
//

import Foundation
import CoreData


extension ColorList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ColorList> {
        return NSFetchRequest<ColorList>(entityName: "ColorList")
    }

    @NSManaged public var colorValue: NSObject?
    @NSManaged public var descriptionColor: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var order: Int16

}

extension ColorList : Identifiable {

}
