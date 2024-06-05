//
//  Logs+CoreDataProperties.swift
//  MyDivingApp
//
//  Created by aman on 4/6/2024.
//
//

import Foundation
import CoreData


extension Logs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Logs> {
        return NSFetchRequest<Logs>(entityName: "Logs")
    }

    @NSManaged public var title: String?
    @NSManaged public var type: Int32
    @NSManaged public var location: String?
    @NSManaged public var date: String?

}

extension Logs : Identifiable {

}

