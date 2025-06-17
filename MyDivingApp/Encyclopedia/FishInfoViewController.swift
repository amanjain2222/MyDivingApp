//
//  FishInfoViewController.swift
//  MyDivingApp
//
//  Created by aman on 16/5/2024.
//

import UIKit


// responsable to take input from the user and displaying matching results, Responsable for making API calls


class FishInfoViewController: UIViewController{
    
    let Species_Segue = "FishSpeciesSegue"
    
    var Key = "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3"
    var REQUEST_STRING = "https://fish-species.p.rapidapi.com/fish_api/fish/"
    var fishSpecies: [FishInfo]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func requestFishData(_ fishName: String) async{
        
        let queryString = fishName
        
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else { print("Invalid URL.")
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        
        urlRequest.allHTTPHeaderFields = [
            "X-RapidAPI-Key": Key,
            "X-RapidAPI-Host": "fish-species.p.rapidapi.co",
            "Content-Type": "application/json"
        ]
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let fishInfoObject = try decoder.decode([FishInfo].self, from: data)
            fishSpecies = fishInfoObject
        }
        catch {
            fatalError()
        }
    }
    
    
    
    @IBOutlet weak var fishName: UITextField!
    
    @IBAction func GetFishSpecies(_ sender: Any) {
        if fishName.text == ""{
            displayMessage(title: "Empty Text Feild", message: "Please enter a fish name")
            return
        }
        
        Task{
            await requestFishData(fishName.text!)
            performSegue(withIdentifier: Species_Segue, sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Species_Segue{
            let destination = segue.destination as! FishSpeciesListTableViewController
            destination.fishSpecies = fishSpecies
            
        }
    }
    
    
    
}
