//
//  FilterViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 18/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import SDWebImage


enum FilterSelection {
    case category
    case neighbourhood
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var categoryButton: SegButton!
    @IBOutlet weak var neighbourhoodButton: SegButton!
    @IBOutlet weak var tableView: UITableView!
    
    var filterSelection: FilterSelection = .category
    var selectedCategoryIds = [String]()
    var selectedNeighbourhoods = [String]()
    
    var neighbourhoods = ["Ballard", "Belltown", "Capitol Hill", "Downtown", "Fremont", "Greenwood", "Magnolia", "Phinney Ridge", "Pioneer Square",  "Queen Anne",  "South Lake Union", "Wallingford", "West Seattle" ]
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = grayColor
        categoryButton.highlightedStateColor()
        neighbourhoodButton.normalStateColor()
        categoryButtonAction()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        
        self.selectedNeighbourhoods = SharedObjects.shared.neighbourhoods
        self.selectedCategoryIds = SharedObjects.shared.categoryIds
        
        self.tableView.register(UINib.init(nibName: "FilterCell", bundle: nil), forCellReuseIdentifier: "FilterCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        if SharedObjects.shared.categories.count == 0 {
            Downloader.retrieveCategories()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let locationManager = ATCLocation.shared
        locationManager.requestLocation()
    }
    
    @IBAction func filterButtonAction() {
        self.dismiss(animated: true, completion: {})
    }

    @IBAction func categoryButtonAction() {
        self.filterSelection = .category
        self.categoryButton.highlightedStateColor()
        self.neighbourhoodButton.normalStateColor()
        self.tableView.reloadData()
    }
    
    @IBAction func neighbourhoodButtonAction() {
        self.filterSelection = .neighbourhood
        self.neighbourhoodButton.highlightedStateColor()
        self.categoryButton.normalStateColor()
        self.tableView.reloadData()
    }
    
    @IBAction func clearAllFilter() {
        self.selectedCategoryIds = [String]()
        self.selectedNeighbourhoods = [String]()
        self.tableView.reloadData()
    }
    
    @IBAction func applyFilter() {
        SharedObjects.shared.categoryIds = self.selectedCategoryIds
        SharedObjects.shared.neighbourhoods = self.selectedNeighbourhoods
        SharedObjects.shared.canReloadStore = true
        self.dismiss(animated: true, completion: nil)
    }
}


extension FilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (filterSelection == .category) ? SharedObjects.shared.categories.count : neighbourhoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        
        if filterSelection == .category {
            let category = SharedObjects.shared.categories[indexPath.row]
            cell.categoryLabel.text = category.name
            if let imageUrl = URL.init(string: category.imageUrl) {
                cell.filterImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage.init(named: "placeholder"), options: [SDWebImageOptions.retryFailed, .handleCookies, .scaleDownLargeImages, .transformAnimatedImage], completed:nil)
            } else {
                cell.filterImageView.image = UIImage.init(named: "placeholder")
            }
            if category.name == "All" { cell.filterImageView.image = UIImage.init(named: "allStores") }
            cell.filterImageView.isHidden = false
            cell.imageViewWidthConstraint.constant = 30
            
            if selectedCategoryIds.contains(category.categoryId) {
                cell.selectionImageView.image = UIImage.init(named: "check_box")
            } else {
                cell.selectionImageView.image = UIImage.init(named: "check_box_blank")
            }
        } else {
            cell.filterImageView.isHidden = true
            let neighbour = neighbourhoods[indexPath.row]
            cell.categoryLabel.text = neighbour
            cell.imageViewWidthConstraint.constant = 0
            
            if selectedNeighbourhoods.contains(neighbour) {
                cell.selectionImageView.image = UIImage.init(named: "check_box")
            } else {
                cell.selectionImageView.image = UIImage.init(named: "check_box_blank")
            }
        }
        cell.selectionImageView.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if filterSelection == .category {
            
            let categoryId = SharedObjects.shared.categories[indexPath.row].categoryId
            
            if categoryId == "-1" {
                selectedCategoryIds = SharedObjects.shared.categories.map{ return $0.categoryId }
                self.tableView.reloadData()
                return
            }
            if selectedCategoryIds.contains(categoryId) {
                selectedCategoryIds = selectedCategoryIds.filter{ $0 != categoryId }
            } else {
                selectedCategoryIds = selectedCategoryIds + [categoryId]
            }
            
        } else {
            let neighbourhood = neighbourhoods[indexPath.row]
            
            if neighbourhood == "All" {
                selectedNeighbourhoods = neighbourhoods
                self.tableView.reloadData()
                return
            }
            
            if selectedNeighbourhoods.contains(neighbourhood) {
                selectedNeighbourhoods = selectedNeighbourhoods.filter{ $0 != neighbourhood }
            } else {
                selectedNeighbourhoods = selectedNeighbourhoods + [neighbourhood]
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
