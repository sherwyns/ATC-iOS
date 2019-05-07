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

protocol FilterAction {
    func clear()
    func apply() -> (categories: [String], neighborhood: [String])
}

protocol ReloadDelegate: class  {
    func reload(section: Int)
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var categoryButton: SegButton!
    @IBOutlet weak var neighbourhoodButton: SegButton!
    @IBOutlet weak var tableView: UITableView!
    
    var filterSelection: FilterSelection = .category {
        didSet {
            if let filterDelegate = self.filterdelegate as? StoreFilterDataSourceDelegate {
                filterDelegate.filterSelection = filterSelection
            }
            if let filterDelegate = self.filterdelegate as? ProductFilterDataSourceDelegate {
                filterDelegate.filterSelection = filterSelection
            }
        }
    }
    var entityType: EntityType = .Store
    
    var tableViewDataSource: UITableViewDataSource!
    var tableViewDelegate: UITableViewDelegate!
    var filterdelegate: FilterAction?
    
    var neighbourhoods = ["Ballard", "Belltown", "Capitol Hill", "Downtown", "Fremont", "Greenwood", "Magnolia", "Phinney Ridge", "Pioneer Square",  "Queen Anne",  "South Lake Union", "Wallingford", "West Seattle" ]
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = grayColor
        categoryButton.highlightedStateColor()
        neighbourhoodButton.normalStateColor()
        categoryButtonAction()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        
        let dummyViewHeight = CGFloat(40)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        self.tableView.register(UINib.init(nibName: "ProductFilterCell", bundle: nil), forCellReuseIdentifier: "ProductFilterCell")
        self.tableView.register(UINib.init(nibName: "FilterCell", bundle: nil), forCellReuseIdentifier: "FilterCell")
        
        self.tableView.register(UINib.init(nibName: "ProductFilterSectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ProductFilterSectionView")
        
        if entityType == .Store {
            let storeFilterDataSourceDelegate = StoreFilterDataSourceDelegate()
            
            storeFilterDataSourceDelegate.selectedNeighbourhoods = SharedObjects.shared.neighbourhoods
            storeFilterDataSourceDelegate.selectedCategoryIds    = SharedObjects.shared.categoryIds
            storeFilterDataSourceDelegate.filterSelection = self.filterSelection
            
            tableViewDataSource = storeFilterDataSourceDelegate
            tableViewDelegate = storeFilterDataSourceDelegate
            
            self.tableView.dataSource = tableViewDataSource
            self.tableView.delegate = tableViewDelegate
            
            self.filterdelegate = storeFilterDataSourceDelegate
        } else {
            let productFilterDataSourceDelegate = ProductFilterDataSourceDelegate()
            
            productFilterDataSourceDelegate.selectedNeighbourhoods = SharedObjects.shared.productNeighbourhoods
            productFilterDataSourceDelegate.selectedCategoryIds    = SharedObjects.shared.productCategoryIds
            productFilterDataSourceDelegate.filterSelection = self.filterSelection
            
            productFilterDataSourceDelegate.reloadDelegate = self
            
            tableViewDataSource = productFilterDataSourceDelegate
            tableViewDelegate = productFilterDataSourceDelegate
            
            self.tableView.dataSource = tableViewDataSource
            self.tableView.delegate = tableViewDelegate
            
            self.filterdelegate = productFilterDataSourceDelegate
        }
        
        if SharedObjects.shared.categories.count == 0 {
            Downloader.retrieveStoreCategories()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.filterdelegate?.clear()
        self.tableView.reloadData()
    }
    
    @IBAction func applyFilter() {
        if entityType == .Store {
            SharedObjects.shared.categoryIds = self.filterdelegate?.apply().categories ?? [String]()
            SharedObjects.shared.neighbourhoods = self.filterdelegate?.apply().neighborhood ?? [String]()
        } else {
            SharedObjects.shared.productCategoryIds = self.filterdelegate?.apply().categories ?? [String]()
            SharedObjects.shared.productNeighbourhoods = self.filterdelegate?.apply().neighborhood ?? [String]()
        }
        
        SharedObjects.shared.canReloadStore = true
        self.dismiss(animated: true, completion: nil)
    }
}



extension FilterViewController: ReloadDelegate {
    func reload(section: Int) {
        self.tableView.reloadSections(IndexSet.init(integer: section), with: .none)
    }
}


class StoreFilterDataSourceDelegate: NSObject, UITableViewDataSource {
    var filterSelection: FilterSelection = .category
    var selectedCategoryIds = [String]()
    var selectedNeighbourhoods = [String]()
    
    var neighbourhoods = ["Ballard", "Belltown", "Capitol Hill", "Downtown", "Fremont", "Greenwood", "Magnolia", "Phinney Ridge", "Pioneer Square",  "Queen Anne",  "South Lake Union", "Wallingford", "West Seattle" ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filterSelection == .category) ? SharedObjects.shared.categories.count : neighbourhoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        
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

extension StoreFilterDataSourceDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if filterSelection == .category {
            let categoryId = SharedObjects.shared.categories[indexPath.row].categoryId
            
            if selectedCategoryIds.contains(categoryId) {
                selectedCategoryIds = selectedCategoryIds.filter{ $0 != categoryId }
            } else {
                selectedCategoryIds = selectedCategoryIds + [categoryId]
            }
            
        } else {
            let neighbourhood = neighbourhoods[indexPath.row]
            
            if selectedNeighbourhoods.contains(neighbourhood) {
                selectedNeighbourhoods = selectedNeighbourhoods.filter{ $0 != neighbourhood }
            } else {
                selectedNeighbourhoods = selectedNeighbourhoods + [neighbourhood]
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension StoreFilterDataSourceDelegate: FilterAction {
    func clear() {
        self.selectedCategoryIds = [String]()
        self.selectedNeighbourhoods = [String]()
    }
    
    func apply() -> (categories: [String], neighborhood: [String]) {
        return (selectedCategoryIds, selectedNeighbourhoods)
    }
}

class ProductFilterDataSourceDelegate: NSObject, UITableViewDataSource {
    var filterSelection: FilterSelection = .category
    var selectedCategoryIds = [String]()
    var selectedNeighbourhoods = [String]()
    weak var reloadDelegate: ReloadDelegate?
    var neighbourhoods = ["Ballard", "Belltown", "Capitol Hill", "Downtown", "Fremont", "Greenwood", "Magnolia", "Phinney Ridge", "Pioneer Square",  "Queen Anne",  "South Lake Union", "Wallingford", "West Seattle" ]
    
    @objc func didSelectHeader(sender: UIButton) {
        let category = SharedObjects.shared.productCategories[sender.tag]
        let subCategoryIds = category.subProductCategories.map{return $0.productId}
        
        if (category.subProductCategories.count == 0) && !isMainOrSubCategoryPresent(id: category.productId) {
            selectedCategoryIds.append(category.productId)
        } else {
            selectedCategoryIds.removeAll { $0 == category.productId }
        }
        
        if isMainOrSubCategoryPresent(id: category.productId) {
            selectedCategoryIds.removeAll{subCategoryIds.contains($0)}
        } else {
            selectedCategoryIds.append(contentsOf: subCategoryIds)
        }
        
        self.reloadDelegate?.reload(section: sender.tag)
    }
    
    @objc func expandOrShrinkRow(sender: UIButton) {
        print(sender.tag)
        let category = SharedObjects.shared.productCategories[sender.tag]
        
        category.isExpanded = !category.isExpanded
        
        for category in SharedObjects.shared.productCategories {
            print(category.isExpanded)
        }
        
        self.reloadDelegate?.reload(section: sender.tag)
    }
    
    
    func isMainOrSubCategoryPresent(id: String) -> Bool {
        // get main category
        var categoryIds: [String] = [String]()
        categoryIds.append(id)
        
        // append all (main + sub's)
        if let category = SharedObjects.shared.productCategories.first(where: {$0.productId == id}) {
            let subCategoryIds = category.subProductCategories.map{return $0.productId}
            categoryIds.append(contentsOf: subCategoryIds)
        }
        
        // check anyone is available
        for selectedCategoryId in selectedCategoryIds {
            for categoryId in categoryIds {
                if selectedCategoryId == categoryId {
                    return true
                }
            }
        }
        
        return false
    }
    
    func removeMainCategory(mainId:String) {
        var categoryIds: [String] = [String]()
        categoryIds.append(mainId)
        
        // append all (main + sub's)
        if let category = SharedObjects.shared.productCategories.first(where: {$0.productId == mainId}) {
            let subCategoryIds = category.subProductCategories.map{return $0.productId}
            categoryIds.append(contentsOf: subCategoryIds)
        }
        
        SharedObjects.shared.productCategoryIds.removeAll { categoryIds.contains($0) }
        
    }
    
    func isAllSubCategoriesSelected(productCategory: ProductCategory) -> Bool {
        let subCategoryIds = productCategory.subProductCategories.map{return $0.productId}
        let setOfSubCategoryIds = Set.init(subCategoryIds)

        let intersectedSet = setOfSubCategoryIds.intersection(selectedCategoryIds)
        
        return (intersectedSet.count == subCategoryIds.count) ? true : false
    }
    
    func selectedSubCategoriesCount(productCategory: ProductCategory) -> Int {
        let subCategoryIds = productCategory.subProductCategories.map{return $0.productId}
        let setOfSubCategoryIds = Set.init(subCategoryIds)
        
        let diffedSet = setOfSubCategoryIds.subtracting(selectedCategoryIds)
        
        return (diffedSet.count == 0) ? subCategoryIds.count : subCategoryIds.count - diffedSet.count
    }
}

extension ProductFilterDataSourceDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (filterSelection == .category) ? SharedObjects.shared.productCategories.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterSelection == .category {
            let category = SharedObjects.shared.productCategories[section]
            if category.isExpanded {
                return category.subProductCategories.count
            } else {
                return 0
            }
        } else {
            return neighbourhoods.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        
        if filterSelection == .category {
            let productCategoryCell = tableView.dequeueReusableCell(withIdentifier: "ProductFilterCell") as! ProductFilterCell
            let sectionProductCategory = SharedObjects.shared.productCategories[indexPath.section]
            
            let subProductCategory = sectionProductCategory.subProductCategories[indexPath.row]
            
            
            productCategoryCell.categoryLabel.text = subProductCategory.name
            
            if selectedCategoryIds.contains(subProductCategory.productId) {
                productCategoryCell.selectionImageView.image = UIImage.init(named: "check_box")
            } else {
                productCategoryCell.selectionImageView.image = UIImage.init(named: "check_box_blank")
            }
            
            productCategoryCell.selectionImageView.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
            return productCategoryCell
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProductFilterSectionView") as! ProductFilterSectionView
        let filterCategory = SharedObjects.shared.productCategories[section]
        headerCell.categoryLabel.text = filterCategory.name
        
        headerCell.expandButton.addTarget(self, action: #selector(ProductFilterDataSourceDelegate.expandOrShrinkRow(sender:)), for: .touchUpInside)
        
        headerCell.fullTapButton.addTarget(self, action: #selector(ProductFilterDataSourceDelegate.didSelectHeader(sender:)), for: .touchUpInside)
        
        headerCell.expandButton.tag = section
        headerCell.fullTapButton.tag = section
        
        if isMainOrSubCategoryPresent(id: filterCategory.productId) {
            headerCell.selectionImageView.image = UIImage.init(named: "check_box")
        } else {
            headerCell.selectionImageView.image = UIImage.init(named: "check_box_blank")
        }
        
        if isAllSubCategoriesSelected(productCategory: filterCategory) {
            headerCell.badgeLabel.text = "All"
            headerCell.badgeLabel.isHidden = false
        } else {
            let selectedCount = selectedSubCategoriesCount(productCategory: filterCategory)
            
            if selectedCount == 0 {
                headerCell.badgeLabel.isHidden = true
            } else {
                headerCell.badgeLabel.isHidden = false
                headerCell.badgeLabel.text = String(selectedCount)
            }
        }
        
        if filterCategory.subProductCategories.count == 0 {
            headerCell.badgeLabel.isHidden = true
            headerCell.expandButton.isHidden = true
        } else {
            headerCell.expandButton.isHidden = false
        }
        
        headerCell.expandButton.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        headerCell.selectionImageView.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filterSelection == .category ? 44 : 0
    }
}

extension ProductFilterDataSourceDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if filterSelection == .category {
            let category = SharedObjects.shared.productCategories[indexPath.section]
            let subCategory = category.subProductCategories[indexPath.row]
            
            if selectedCategoryIds.contains(subCategory.productId) {
                selectedCategoryIds.removeAll{$0 == subCategory.productId}
            } else {
                selectedCategoryIds.append(subCategory.productId)
            }
            
        } else {
            let neighbourhood = neighbourhoods[indexPath.row]
            
            if selectedNeighbourhoods.contains(neighbourhood) {
                selectedNeighbourhoods = selectedNeighbourhoods.filter{ $0 != neighbourhood }
            } else {
                selectedNeighbourhoods = selectedNeighbourhoods + [neighbourhood]
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ProductFilterDataSourceDelegate: FilterAction {
    func clear() {
        self.selectedCategoryIds = [String]()
        self.selectedNeighbourhoods = [String]()
    }
    
    func apply() -> (categories: [String], neighborhood: [String]) {
        return (selectedCategoryIds, selectedNeighbourhoods)
    }
}
