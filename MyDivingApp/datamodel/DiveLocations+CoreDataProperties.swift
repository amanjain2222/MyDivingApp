//
//  DiveLocations+CoreDataProperties.swift
//  MyDivingApp
//
//  Created by aman on 7/6/2024.
//
//

import Foundation
import CoreData


extension DiveLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiveLocations> {
        return NSFetchRequest<DiveLocations>(entityName: "DiveLocations")
    }

    @NSManaged public var location: String?

}

extension DiveLocations : Identifiable {

}
