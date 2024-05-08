//
//  LocationsTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 1/5/2024.
//

import UIKit

class LocationsTableViewController: UITableViewController, UISearchBarDelegate, UpdateLoctionDelegate, UISearchResultsUpdating {
    
    
    let searchController = UISearchController(searchResultsController: nil)
    let CELL_SITE = "diveSiteCell"
    let REQUEST_STRING = "https://world-scuba-diving-sites-api.p.rapidapi.com/api/divesite?country="
    let Key = "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3"
    var newSites = [DiveSites]()
    var filteredSites = [DiveSites]()
    
    var indicator = UIActivityIndicatorView()
    var currentSite: DiveSites?
    var CurrentLocation: String?
    
    weak var mapViewController: MapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        
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
            CurrentLocationButton.title = "set location v"
        }else{
            CurrentLocationButton.title = CurrentLocation
        }
    }
    
    func hideSearchBar() -> Bool{
        if newSites.isEmpty{
            return true
        }
        return false
    }
    
    func requestDiveSites(_ region: String) async{
        
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "world-scuba-diving-sites-api.p.rapidapi.com"
        searchURLComponents.path = "/api/divesite"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "country", value: region)
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
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let diveSiteObject = try decoder.decode(DiveSiteObject.self, from: data)
            if let diveSites = diveSiteObject.diveSites {
                newSites.append(contentsOf: diveSites)
                filteredSites = newSites
                searchController.searchBar.isHidden = hideSearchBar()
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
        return filteredSites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SITE, for: indexPath)
        
        let site = filteredSites[indexPath.row]
        cell.textLabel?.text = site.name
        cell.detailTextLabel?.text = site.region

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentSite = filteredSites[indexPath.row]
        guard let latitude = Double((currentSite?.latitude)!) else {return}
        guard let longitude = Double((currentSite?.longitude)!) else {return}
        
        let mapAnnotation = LocationAnnotation(title: (currentSite?.name)!, subtitle: (currentSite?.region)!, lat: latitude , long: longitude)
        
        mapViewController?.mapView.addAnnotation(mapAnnotation)
        mapViewController?.focusOn(annotation: mapAnnotation)
        
        splitViewController?.show(.secondary)
    }
    
    
    @IBOutlet weak var CurrentLocationButton: UIBarButtonItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "diveSiteInfo"{
//            let destination = segue.destination as! DiveSiteViewController
//            destination.currentSite = currentSite
//        }
        
        if segue.identifier == "updateCurrentLocation"{
            let destination = segue.destination as! CurrentLocationViewController
            destination.delegate = self
        }
        
        return
    }
    


    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
