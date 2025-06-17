//
//  Logs+CoreDataClass.swift
//  MyDivingApp
//
//  Created by aman on 6/6/2024.
//
//

 import Foundation
 import CoreData


 enum TypeOFDive: Int32{
     
     case shore = 0
     case boat = 1
     case pier = 2
     case other = 3
 }


 @objc(Logs)
 public class Logs: NSManagedObject {

 }


 extension Logs{
     var DiveType: TypeOFDive{
         get{
             return TypeOFDive(rawValue: self.type)!
         }
         set{
             self.type = newValue.rawValue
         }
     }
 }
 
