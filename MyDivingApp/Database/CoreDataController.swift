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
        // Initialize the Core Data stack
        persistentContainer = NSPersistentContainer(name: "DivingCoreData")
        persistentContainer.loadPersistentStores() {(description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    
    // Save changes if there are any
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    // Add a new dive location if it doesn't already exist
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
    
    
    
    // Delete a dive location
    func deleteLocation(location: DiveLocations){
        
        persistentContainer.viewContext.delete(location)
    }
    
    
    
    // Add log entry
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
    
    
    
    // Delete a log entry
    func deleteLogCoredata(log: Logs) {
        
        persistentContainer.viewContext.delete(log)
    }
    
    
    
    
    // Fetch all dive locations
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

        if locationFetchedResultsController?.fetchedObjects != nil {
            allLocations = (locationFetchedResultsController?.fetchedObjects)!
        }

        return allLocations
    }
    
    
    // Fetch all log entries
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
    
    
    
    // Add a listener for database changes
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
    
    
    
    // Check if user is signed in, By default is is set to tru because if the user is signed out, that would mean the user is using the app anonymously
    // this would be false/true when using firebase storage instead of coredata
    func isSignedIn() -> Bool {
        return true
    }
    
    
    
    // Check if the database is Core Data
    func isCoredata() -> Bool{
        return true
    }
    
    
    
    // Handle content changes in the fetched results controller
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
