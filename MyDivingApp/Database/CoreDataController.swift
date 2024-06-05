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
    
    func addlogCoredata(title: String, divetype: TypeOFDive, DiveLocation: String, DiveDate: String) -> Logs {
        
        let log = NSEntityDescription.insertNewObject(forEntityName: "Logs", into: persistentContainer.viewContext) as! Logs
        
        log.title = title
        log.DiveType = divetype
        log.location = DiveLocation
        log.date = DiveDate
        
        return log
        
    }
    
    func deletelog(log: Logs) {
        
        persistentContainer.viewContext.delete(log)
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
    }

}
