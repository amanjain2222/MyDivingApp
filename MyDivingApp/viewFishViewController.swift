//
//  viewFishViewController.swift
//  MyDivingApp
//
//  Created by aman on 26/5/2024.
//

import UIKit

class viewFishViewController: UIViewController {
    
    var fish: FishInfo?

    override func viewDidLoad()  {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Task{
            if let imageURL = fish?.fishImage{
                await loadFishImage(imageURL: imageURL)
                
            }else{
                fishImage.image = nil
            }
            
        }
        
        wikiUrl.text = "\((fish?.url) ?? "Not Available")"
        
        synonym.text = "Synonyms: \((fish?.synonyms) ?? "Not Available")"
        
        species.text = "Species: \((fish?.species) ?? "Not Available")"
        
        species2.text = "species: \((fish?.species2) ?? "Not Available")"
        
        binomial_name.text = "Bionomial name: \((fish?.binomial_name) ?? "Not Available")"
        
        conservation_stat.text = "Conservation Status: \((fish?.conservation_status) ?? "Not Available")"
        
        domein.text = "Domain: \((fish?.domain) ?? "Not Available")"
        
        kingdom.text = "Kingdom: \((fish?.kingdom) ?? "Not Available" )"
        
        phylum.text = "Phylum: \((fish?.phylum) ?? "Not Available")"
        
        fishClass.text = "Class: \((fish?.fishClass) ?? "Not Available")"
        
        superOrder.text = "Super-order: \((fish?.superorder) ?? "Not Available")"
        
        order.text = "Order: \((fish?.order) ?? "Not Available")"
        
        family.text = "Family: \((fish?.family) ?? "Not Available")"
        
        tribe.text = "Tribe: \((fish?.tribe) ?? "Not Available")"
        
        genus.text = "Genus: \((fish?.genus) ?? "Not Available")"
        
        subgenus.text = "Sub-genus: \((fish?.subgenus) ?? "Not Available")"
        
        
        
        
    }
    
        func loadFishImage(imageURL: String) async{
    
    
                guard let requestURL = URL(string: imageURL) else { print("Invalid URL.")
                    return
                }
    
                let urlRequest = URLRequest(url: requestURL)
    
                do {
    
                    let (data, _) = try await URLSession.shared.data(for: urlRequest)
    
                    if let image = UIImage(data: data) {
                        fishImage.image = image
                    }
                }
                catch let error {
                    print(error)
                }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var fishImage: UIImageView!
    
    @IBOutlet weak var wikiUrl: UILabel!
    
    @IBOutlet weak var synonym: UILabel!
    
    @IBOutlet weak var species: UILabel!
    
    @IBOutlet weak var species2: UILabel!
    
    @IBOutlet weak var binomial_name: UILabel!
    
    @IBOutlet weak var conservation_stat: UILabel!
    
    @IBOutlet weak var domein: UILabel!
    
    @IBOutlet weak var kingdom: UILabel!
    
    @IBOutlet weak var phylum: UILabel!
    
    @IBOutlet weak var fishClass: UILabel!
    
    @IBOutlet weak var superOrder: UILabel!
    
    @IBOutlet weak var order: UILabel!
    
    @IBOutlet weak var family: UILabel!
    
    @IBOutlet weak var tribe: UILabel!
    
    @IBOutlet weak var genus: UILabel!
    
    @IBOutlet weak var subgenus: UILabel!
    
}
