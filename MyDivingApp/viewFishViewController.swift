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
        
        wikiUrl.text = "\(String(describing: (fish?.url)))"
        
        synonym.text = "Synonyms: \(String(describing: (fish?.synonyms)))"
        
        species.text = "Species: \(String(describing: (fish?.species)))"
        
        species2.text = "species: \(String(describing: (fish?.species2)))"
        
        binomial_name.text = "Bionomial name: \(String(describing: (fish?.binomial_name)))"
        
        conservation_stat.text = "Conservation Status: \(String(describing: (fish?.conservation_status)))"
        
        domein.text = "Domain: \(String(describing: (fish?.domain)))"
        
        kingdom.text = "Kingdom: \(String(describing: (fish?.kingdom)))"
        
        phylum.text = "Phylum: \(String(describing: (fish?.phylum)))"
        
        fishClass.text = "Class: \(String(describing: (fish?.fishClass)))"
        
        superOrder.text = "Super-order: \(String(describing: (fish?.superorder)))"
        
        order.text = "Order: \(String(describing: (fish?.order)))"
        
        family.text = "Family: \(String(describing: (fish?.family)))"
        
        tribe.text = "Tribe: \(String(describing: (fish?.tribe)))"
        
        genus.text = "Genus: \(String(describing: (fish?.genus)))"
        
        subgenus.text = "Sub-genus: \(String(describing: (fish?.subgenus)))"
        
        
        
        
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
