//
//  FishSpeciesListTableViewController.swift
//  MyDivingApp
//
//  Created by aman on 26/5/2024.
//

import UIKit


 //this class is reponsable to view matching soecies that the user asked for

class FishSpeciesListTableViewController: UITableViewController {
    
    var fishSpecies: [FishInfo]?
    var FishSegue = "ShowFishDetails"
    override func viewDidLoad()  {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fishSpecies!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciesCell", for: indexPath)
        
        let species = fishSpecies![indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = species.name
        cell.contentConfiguration = content
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let fish = fishSpecies![indexPath.row]
        performSegue(withIdentifier: FishSegue, sender: fish)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == FishSegue{
            
            let destination = segue.destination as! viewFishViewController
            destination.fish = sender as? FishInfo
        }
    }
    

}
