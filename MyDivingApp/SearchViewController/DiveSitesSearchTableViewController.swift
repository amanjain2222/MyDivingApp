//
//  DiveSitesSearchTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 24/4/2024.
//

import UIKit

class DiveSitesSearchTableViewController: UITableViewController, UISearchBarDelegate, UpdateLoctionDelegate, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    let CELL_SITE = "diveSiteCell"
    let REQUEST_STRING = "https://world-scuba-diving-sites-api.p.rapidapi.com/api/divesites?query="
    let Key = "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3"
    
    var newSites = [DiveSites]()
    var filteredSites = [DiveSites]()
    var indicator = UIActivityIndicatorView()
    var currentSite: DiveSites?
    var CurrentLocation: String?
    
    let headers = [
        "X-RapidAPI-Key": "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3",
        "X-RapidAPI-Host": "world-scuba-diving-sites-api.p.rapidapi.com"
    ]
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.coreDatabaseController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Dive Site"
        navigationItem.searchController = searchController
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
        searchController.searchBar.isHidden = hideSearchBar()
        
        
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        
        if CurrentLocation == nil {
            CurrentLocationButton.title = "Set Location: "
        }else{
            CurrentLocationButton.title = CurrentLocation
        }
        tableView.separatorStyle = .none
    }
    
    
    func hideSearchBar() -> Bool{
        if newSites.isEmpty{
            return true
        }
        return false
    }
    
    
    @IBOutlet weak var CurrentLocationButton: UIBarButtonItem!
    
    
    
    //making request to API for dive sites, if not returned error is properly managed and displayed to the user
    func requestDiveSites(_ region: String) async{
        
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "world-scuba-diving-sites-api.p.rapidapi.com"
        searchURLComponents.path = "/divesites"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "query", value: region)
        ]
        
        guard let requestURL = searchURLComponents.url else { print("Invalid URL.")
            return
        }
        var urlRequest = URLRequest(url: requestURL)
        
        urlRequest.allHTTPHeaderFields = [
            "X-RapidAPI-Key": Key,
            "X-RapidAPI-Host": "world-scuba-diving-sites-api.p.rapidapi.com"
        ]
        
        do {
            let (data,_ ) = try await URLSession.shared.data(for: urlRequest)
            
            indicator.stopAnimating()
            let decoder = JSONDecoder()
            let diveSiteObject = try decoder.decode(DiveSiteObject.self, from: data)
            if let diveSites = diveSiteObject.diveSites {
                if diveSites.isEmpty {
                    displayMessage(title: "Error 404 \(region) not found", message: "Please check for spelling mistakes and try again")
                    return
                }
                
                _ = databaseController?.addDiveLocation(location: region)
                newSites.append(contentsOf: diveSites)
                filteredSites = newSites
                searchController.searchBar.isHidden = hideSearchBar()
                tableView.separatorStyle = .singleLine
                tableView.reloadData()
            }
            
            
        }
        catch let error {
            print(error)
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController){
        
        guard let searchText = searchController.searchBar.text?.lowercased()
        else {
            return
        }
        
        if searchText.count > 0 {
            filteredSites = newSites.filter({ (Site: DiveSites) -> Bool in
                return Site.name?.lowercased().contains(searchText) ?? false
            })
        } else {
            filteredSites = newSites
        }
        tableView.reloadData()
        
    }
    
    
    func UpdateCurrentLocation(_ Location: String?) {
        if Location != "" && Location != CurrentLocation{
            newSites.removeAll()
            CurrentLocationButton.title = Location
            indicator.startAnimating()
            Task{
                URLSession.shared.invalidateAndCancel()
                await requestDiveSites(Location!)
            }
        }
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if filteredSites.count != 0{
            return filteredSites.count
        }else{
            return 1
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if filteredSites.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SITE, for: indexPath)
            // Configure the cell...
            let site = filteredSites[indexPath.row]
            cell.textLabel?.text = site.name
            cell.detailTextLabel?.text = site.region
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WelcomeCell", for: indexPath)
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if filteredSites.count == 0 {
            return 500
        }
        
        
        // Use the default size for all other rows.
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if filteredSites.count == 0 {
            return nil
        }
        return indexPath
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSite = filteredSites[indexPath.row]
        performSegue(withIdentifier: "diveSiteInfo", sender: nil)
        
    }
    
    
    //doing some preparation and using delegation to cummunicate and passing info to other controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "diveSiteInfo"{
            let destination = segue.destination as! DiveSiteViewController
            destination.currentSite = currentSite
        }
        
        if segue.identifier == "updateCurrentLocation"{
            let destination = segue.destination as! CurrentLocationViewController
            destination.delegate = self
        }
        
        return
    }

    
}
