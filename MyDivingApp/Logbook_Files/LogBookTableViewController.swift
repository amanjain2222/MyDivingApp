//
//  LogBookTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 8/5/2024.
//

import UIKit

class LogBookTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType: ListenerType = .Userlogs
    
    // Sections for different dive types
    var section_shore = 0
    var section_boat = 1
    var section_pier = 2
    var section_other = 3
    
    // Sections for CoreData dive types
    var section_warning_cell = 0
    var section_shore_Coredata = 1
    var section_boat_Coredata = 2
    var section_pier_Coredata = 3
    var section_other_Coredata = 4
    
    // Current selected log
    var currentLog: diveLogs?
    var currentLogcoredata: Logs?
    
    // Arrays to store different types of dive
    var shoreDives: [diveLogs] = []
    var boatDives: [diveLogs] = []
    var pierDives: [diveLogs] = []
    var otherDives: [diveLogs] = []
    
    
    var shoreDivesCoredata: [Logs] = []
    var boatDivesCoredata: [Logs] = []
    var pierDivesCoredata: [Logs] = []
    var otherDivesCoredata: [Logs] = []
    
    
    var indicator = UIActivityIndicatorView()
    weak var databaseController: DatabaseProtocol?
    
    var allLogs: [diveLogs] = []
    var allLogsCoredata: [Logs] = []
    
    
    
    func onLocationChange(change: DatabaseChange, locations: [DiveLocations]) {
        
    }
    
    
    func onLogsChange(change: DatabaseChange, logs: [Logs]) {
        allLogsCoredata = logs
        
        shoreDivesCoredata = allLogsCoredata.filter ({ (log: Logs) -> Bool in
            return log.DiveType == TypeOFDive.shore
        })
        
        boatDivesCoredata = allLogsCoredata.filter ({ (log: Logs) -> Bool in
            return log.DiveType == TypeOFDive.boat
        })
        
        pierDivesCoredata = allLogsCoredata.filter ({ (log: Logs) -> Bool in
            return log.DiveType == TypeOFDive.pier
        })
        
        otherDivesCoredata = allLogsCoredata.filter ({ (log: Logs) -> Bool in
            return log.DiveType == TypeOFDive.other
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        }
        
    }
    
    func onChatChange(change: DatabaseChange, userChannels: [Channel]) {
        
    }
    
    
    func onUserLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        allLogs = logs
        
        shoreDives = allLogs.filter ({ (log: diveLogs) -> Bool in
            return log.diveType == DiveType.shore
        })
        
        boatDives = allLogs.filter ({ (log: diveLogs) -> Bool in
            return log.diveType == DiveType.boat
        })
        
        pierDives = allLogs.filter ({ (log: diveLogs) -> Bool in
            return log.diveType == DiveType.pier
        })
        
        otherDives = allLogs.filter ({ (log: diveLogs) -> Bool in
            return log.diveType == DiveType.other
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        }
        
    }
    
    
    func onAllLogsChange(change: DatabaseChange, logs: [diveLogs]) {
        
    }
    
    

    
    func onAuthenticationChange(ifSucessful: Bool) {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        }
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup database controller and add listeners, according to the signed in status of the user, this determies if we want to use firebase or coredata.
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.addListener(listener: self)
        if databaseController?.isSignedIn() == false{
            databaseController?.removeListener(listener: self)
            databaseController = appDelegate?.coreDatabaseController
            databaseController?.addListener(listener: self)
        }
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.addListener(listener: self)
        if databaseController?.isSignedIn() == false{
            databaseController?.removeListener(listener: self)
            databaseController = appDelegate?.coreDatabaseController
            databaseController?.addListener(listener: self)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if databaseController?.isCoredata() == false{
            if allLogs.count > 0 {
                return 4
            }else{
                return 1
            }
        }
        else{
            if allLogsCoredata.count > 0 {
                return 5
            }else{
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if databaseController?.isCoredata() == false{
            if allLogs.count == 0 {
                return 0
            }else if section == section_shore{
                return shoreDives.count
            }else if section == section_boat{
                return boatDives.count
            }else if section == section_pier{
                return pierDives.count
            }else if section == section_other{
                return otherDives.count
            }else{
                fatalError()
            }
        }
        else{
            if section == section_warning_cell{
                return 1
            }else if section == section_shore_Coredata{
                return shoreDivesCoredata.count
            }else if section == section_boat_Coredata{
                return boatDivesCoredata.count
            }else if section == section_pier_Coredata{
                return pierDivesCoredata.count
            }else if section == section_other_Coredata{
                return otherDivesCoredata.count
            }else{
                fatalError()
            }
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if databaseController?.isCoredata() == false{
            //            if allLogs.count == 0{
            //                let warningcell = tableView.dequeueReusableCell(withIdentifier: "Warning", for: indexPath) as! LogBookWarningViewCell
            //                return warningcell
            //            }
            //            else{
            
            if indexPath.section == section_boat{
                let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                let log = boatDives[indexPath.row]
                var content = logcell.defaultContentConfiguration()
                content.text = log.title
                logcell.contentConfiguration = content
                return logcell
                //            }
            }else if indexPath.section == section_shore{
                let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                let log = shoreDives[indexPath.row]
                var content = logcell.defaultContentConfiguration()
                content.text = log.title
                logcell.contentConfiguration = content
                return logcell
            }else if indexPath.section == section_pier{
                let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                let log = pierDives[indexPath.row]
                var content = logcell.defaultContentConfiguration()
                content.text = log.title
                logcell.contentConfiguration = content
                return logcell
            }else if indexPath.section == section_other{
                let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                let log = otherDives[indexPath.row]
                var content = logcell.defaultContentConfiguration()
                content.text = log.title
                logcell.contentConfiguration = content
                return logcell
            }else{
                fatalError()
            }
        }
        else{
            if allLogsCoredata.count == 0 {
                let warningcell = tableView.dequeueReusableCell(withIdentifier: "Warning", for: indexPath) as! LogBookWarningViewCell
                return warningcell
            }
            else{
                if indexPath.section == section_warning_cell{
                    let warningCell = tableView.dequeueReusableCell(withIdentifier: "warningcell", for: indexPath) as! warningCoredataTableViewCell
                    return warningCell
                    
                } else if indexPath.section == section_boat_Coredata{
                    let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                    let log = boatDivesCoredata[indexPath.row]
                    var content = logcell.defaultContentConfiguration()
                    content.text = log.title
                    logcell.contentConfiguration = content
                    return logcell
                }else if indexPath.section == section_pier_Coredata{
                    let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                    let log = pierDivesCoredata[indexPath.row]
                    var content = logcell.defaultContentConfiguration()
                    content.text = log.title
                    logcell.contentConfiguration = content
                    return logcell
                }else if indexPath.section == section_shore_Coredata{
                    let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                    let log = shoreDivesCoredata[indexPath.row]
                    var content = logcell.defaultContentConfiguration()
                    content.text = log.title
                    logcell.contentConfiguration = content
                    return logcell
                }else if indexPath.section == section_other_Coredata{
                    let logcell = tableView.dequeueReusableCell(withIdentifier: "diveLog", for: indexPath)
                    let log = otherDivesCoredata[indexPath.row]
                    var content = logcell.defaultContentConfiguration()
                    content.text = log.title
                    logcell.contentConfiguration = content
                    return logcell
                }else{
                    fatalError()
                }
            }
            
        }
        
    }
    
    
    //setting the size of warning cells
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        if databaseController?.isCoredata() == false && allLogs.count == 0{
            return 500
        }else if databaseController?.isCoredata() == true && allLogsCoredata.count == 0{
            return 500
        }
        // Use the default size for all other rows.
        return UITableView.automaticDimension
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if databaseController?.isCoredata() == false && allLogs.count == 0{
            return false
        }else if databaseController?.isCoredata() == true && allLogsCoredata.count == 0 {
            return false
        }else if databaseController?.isCoredata() == true && indexPath.section == section_warning_cell {
            return false
        }
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
    
            if databaseController?.isCoredata() == false{
                if indexPath.section == section_boat{
                    self.databaseController?.removeLogFromUserLogs(log: boatDives[indexPath.row])
                    
                }else if indexPath.section == section_shore{
                    self.databaseController?.removeLogFromUserLogs(log: shoreDives[indexPath.row])
                    
                }else if indexPath.section == section_pier{
                    self.databaseController?.removeLogFromUserLogs(log: pierDives[indexPath.row])
                    
                }else if indexPath.section == section_other{
                    self.databaseController?.removeLogFromUserLogs(log: otherDives[indexPath.row])
                    
                }
            }
            else{

                if indexPath.section == section_boat_Coredata{
                    self.databaseController?.deleteLogCoredata(log: boatDivesCoredata[indexPath.row])
                    
                }else if indexPath.section == section_shore_Coredata{
                    self.databaseController?.deleteLogCoredata(log: shoreDivesCoredata[indexPath.row])
                    
                }else if indexPath.section == section_pier_Coredata{
                    self.databaseController?.deleteLogCoredata(log: pierDivesCoredata[indexPath.row])
                    
                }else if indexPath.section == section_other_Coredata{
                    self.databaseController?.deletelog(log: otherDives[indexPath.row])
                    
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if databaseController?.isCoredata() == false{
            if indexPath.section == section_boat{
                let selectedLog = boatDives[indexPath.row]
                currentLog = selectedLog
            }else if indexPath.section == section_shore{
                let selectedLog = shoreDives[indexPath.row]
                currentLog = selectedLog
            }else if indexPath.section == section_pier{
                let selectedLog = pierDives[indexPath.row]
                currentLog = selectedLog
            }else if indexPath.section == section_other{
                let selectedLog = otherDives[indexPath.row]
                currentLog = selectedLog
            }
            
        }else{
            
            if indexPath.section == section_boat_Coredata{
                let selectedLog = boatDivesCoredata[indexPath.row]
                currentLogcoredata = selectedLog
            }else if indexPath.section == section_shore_Coredata{
                let selectedLog = shoreDivesCoredata[indexPath.row]
                currentLogcoredata = selectedLog
            }else if indexPath.section == section_pier_Coredata{
                let selectedLog = pierDivesCoredata[indexPath.row]
                currentLogcoredata = selectedLog
            }else if indexPath.section == section_other_Coredata{
                let selectedLog = otherDivesCoredata[indexPath.row]
                currentLogcoredata = selectedLog
            }
        }
        performSegue(withIdentifier: "showDive", sender: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if databaseController?.isCoredata() == false && allLogs.count == 0{
            return nil
        }else if databaseController?.isCoredata() == true && allLogsCoredata.count == 0{
            return nil
        }else if databaseController?.isCoredata() == true && indexPath.section == section_warning_cell{
            return nil
        }
        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if databaseController?.isCoredata() == false{
            
            if section == section_boat && boatDives.count > 0{
                return "Boat Dives"
            }else if section == section_shore && shoreDives.count > 0{
                return "Shore Dives"
            }else if section == section_pier && pierDives.count > 0{
                return "Pier Dives"
            }else if section == section_other && otherDives.count > 0{
                return "Others"
            }
            
        }else{
            if section == section_boat_Coredata && boatDivesCoredata.count > 0{
                return "Boat Dives"
            }else if section == section_shore_Coredata && shoreDivesCoredata.count > 0{
                return "Shore Dives"
            }else if section == section_pier_Coredata && pierDivesCoredata.count > 0{
                return "Pier Dives"
            }else if section == section_other_Coredata && otherDivesCoredata.count > 0{
                return "Others"
            }
            
        }
        return nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDive"{
            
            let destination = segue.destination as! ViewDiveSiteViewController
            destination.currentLog = currentLog
            destination.currentLogCoredata = currentLogcoredata
            
        }
    }
    
    
    
    @IBOutlet weak var addlogbutton: UIBarButtonItem!
    
}
