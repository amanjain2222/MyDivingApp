//
//  CoreDataController.swift
//  MyDivingApp
//
//  Created by aman on 4/6/2024.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol,NSFetchedResultsControllerDelegate{
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var logsFetchedResultsController: NSFetchedResultsController<Logs>?
    var locationFetchedResultsController: NSFetchedResultsController<DiveLocations>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "DivingCoreData")
        persistentContainer.loadPersistentStores() {(description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addDiveLocation(location: String) -> DiveLocations? {
        let previousSearchedLocations = fetchAllLocations()
        var alreadyPresent: Bool = false
        for divelocation in previousSearchedLocations{
            if divelocation.location?.lowercased() == location.lowercased() {
                alreadyPresent = true
            }
        }
        
        if !alreadyPresent{
            let diveLocation = NSEntityDescription.insertNewObject(forEntityName: "DiveLocations", into: persistentContainer.viewContext) as! DiveLocations
            diveLocation.location = location
            return diveLocation
        }
        return nil
    }
    
    func deleteLocation(location: DiveLocations){
        
        persistentContainer.viewContext.delete(location)
    }
    
    func addlogCoredata(title: String, divetype: TypeOFDive, DiveLocation: String, DiveDate: Date, duration: String, weight: String, comments: String) -> Logs {
        
        let log = NSEntityDescription.insertNewObject(forEntityName: "Logs", into: persistentContainer.viewContext) as! Logs
        
        log.title = title
        log.type = divetype.rawValue
        log.date = DiveDate
        log.location = DiveLocation
        log.duration = duration
        log.weights = weight
        log.comments = comments
        
        return log
        
    }
    
    func deletelog(log: Logs) {
        
        persistentContainer.viewContext.delete(log)
    }
    
    
    func fetchAllLocations() -> [DiveLocations]{
        
        let fetchRequest: NSFetchRequest<DiveLocations> = DiveLocations.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "location", ascending: true)
        
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        locationFetchedResultsController = NSFetchedResultsController<DiveLocations>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        locationFetchedResultsController?.delegate = self
        do {
            try locationFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
            
            var allLocations = [DiveLocations]()
//            var locations: [String] = []
            if locationFetchedResultsController?.fetchedObjects != nil {
                allLocations = (locationFetchedResultsController?.fetchedObjects)!
            }
//            for divelocations in allLocations{
//                locations.append(divelocations.location!)
//            }
            return allLocations
        
    }
    
    
    func fetchAllLogs() -> [Logs] {

        
        if logsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Logs> = Logs.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    
            fetchRequest.sortDescriptors = [nameSortDescriptor]
 
            logsFetchedResultsController = NSFetchedResultsController<Logs>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            logsFetchedResultsController?.delegate = self
            do {
                try logsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        var allLogs = [Logs]()
        if logsFetchedResultsController?.fetchedObjects != nil {
            allLogs = (logsFetchedResultsController?.fetchedObjects)!
        }
        return allLogs
    }
    
    func addListener(listener: DatabaseListener) { 
        listeners.addDelegate(listener)
        
        if listener.listenerType == .Userlogs || listener.listenerType == .all {
            listener.onLogsChange(change: .update, logs: fetchAllLogs())
                                                                                                           
            }
        if listener.listenerType == .diveLocations || listener.listenerType == .all {
            listener.onLocationChange(change: .update, locations: fetchAllLocations())
                                                                                                           
            }
        }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func isSignedIn() -> Bool {
        return true
    }
    
    func isCoredata() -> Bool{
        return true
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if controller == logsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .Userlogs || listener.listenerType == .all {
                    listener.onLogsChange(change: .update, logs: fetchAllLogs())
                }
            }
            }
        
        if controller == locationFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .diveLocations || listener.listenerType == .all {
                    listener.onLocationChange(change: .update, locations: fetchAllLocations())
                }
            }
            
        }
    }

}
