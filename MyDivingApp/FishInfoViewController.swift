//
//  FishInfoViewController.swift
//  MyDivingApp
//
//  Created by aman on 16/5/2024.
//

import UIKit

class FishInfoViewController: UIViewController, UISearchBarDelegate{
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        guard let searchText = searchBar.text, !searchText.isEmpty else{
            return
        }
        navigationItem.searchController?.dismiss(animated: true)
        //indicator.startAnimating()
        Task{
            URLSession.shared.invalidateAndCancel()
            //currentRequestIndex = 0
            await requestFishData(searchText)
        }
    }
    
    var Key = "007d406e35msh8a93dbecf6813cfp15bd95jsn9c435e5f31f3"
    var REQUEST_STRING = "https://fish-species.p.rapidapi.com/fish_api/fish/"
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        // Do any additional setup after loading the view.
    }
    
    func requestFishData(_ fishName: String) async{
        
        var searchURLComponents = URLComponents()
        var queryString = fishName
//        searchURLComponents.scheme = "https"
//        searchURLComponents.host = "fish-species.p.rapidapi.com"
//        searchURLComponents.path = "/fish_api/fish"
//        searchURLComponents.queryItems = [
//            URLQueryItem(name: "name", value: fishName)
//        ]
        
//        guard let requestURL = searchURLComponents.url else { print("Invalid URL.")
//            return
//        }
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
            //indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let fishInfoObject = try decoder.decode([FishInfo].self, from: data)
            if let fishInfo = fishInfoObject.first {
                    // Access the properties of the first FishInfo object
                //name.text = "\(String(describing: fishInfo.id))"
                //name.text = fishInfo.scientificClassification?.domain
                Species.text = fishInfo.species
                print(fishInfo.fishImage)
                navigationItem.title = fishInfo.name
                await loadFishImage(imageURL: fishInfo.fishImage!)
                }
            
            
            
        }
        catch let error {
            print(error)
        }
    }
    
    
    func loadFishImage(imageURL: String) async{

            
            guard let requestURL = URL(string: imageURL) else { print("Invalid URL.")
                return
            }
        
            let urlRequest = URLRequest(url: requestURL)

            do {
                
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                
                if let image = UIImage(data: data) {
                        
                    Image.image = image
                    print(data)
                    
                }
                
            }
            catch let error {
                print(error)
            }
            
            
        
    }
    
    
    @IBOutlet weak var Species: UILabel!
    
    @IBOutlet weak var Image: UIImageView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
