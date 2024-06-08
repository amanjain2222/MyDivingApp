//
//  Logs+CoreDataProperties.swift
//  MyDivingApp
//
//  Created by aman on 6/6/2024.
//
//

import Foundation
import CoreData


extension Logs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Logs> {
        return NSFetchRequest<Logs>(entityName: "Logs")
    }

    @NSManaged public var date: Date?
    @NSManaged public var location: String?
    @NSManaged public var title: String?
    @NSManaged public var type: Int32
    @NSManaged public var duration: String?
    @NSManaged public var weights: String?
    @NSManaged public var comments: String?

}

extension Logs : Identifiable {

}
