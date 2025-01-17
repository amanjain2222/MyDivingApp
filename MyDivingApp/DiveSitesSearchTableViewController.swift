//
//  DiveSitesSearchTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 24/4/2024.
//

import UIKit

class DiveSitesSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_SITE = "diveSiteCell"
    let REQUEST_STRING = "https://world-scuba-diving-sites-api.p.rapidapi.com/api/divesite?country="
    let Key = "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3"
    
    var newSites = [DiveSites]()
    var indicator = UIActivityIndicatorView()
    var currentSite: DiveSites?
    
    let headers = [
        "X-RapidAPI-Key": "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3",
        "X-RapidAPI-Host": "world-scuba-diving-sites-api.p.rapidapi.com"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
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
                tableView.reloadData()
            }
            
        }
        catch let error {
            print(error)
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newSites.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else{
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        Task{
            URLSession.shared.invalidateAndCancel()
            await requestDiveSites(searchText)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newSites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SITE, for: indexPath)

        // Configure the cell...
        // Configure the cell...
        let site = newSites[indexPath.row]
        cell.textLabel?.text = site.name
        cell.detailTextLabel?.text = site.region

        return cell

    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSite = newSites[indexPath.row]
        performSegue(withIdentifier: "diveSiteInfo", sender: nil)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! DiveSiteViewController
        destination.currentSite = currentSite
    }
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
