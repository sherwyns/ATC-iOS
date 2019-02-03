//
//  FilterViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 18/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var entityContainer: UIView!
    @IBOutlet weak var filterButton: UIButton!
    var entityViewController: EntityViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 11, left:11, bottom: 11, right: 11)
        self.view.backgroundColor = grayColor
        
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
        self.entityViewController?.collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    
    @IBAction func filterButtonAction() {
        self.dismiss(animated: true, completion: {})
    }

}


extension FilterViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedObjects.shared.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = SharedObjects.shared.categories[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FilterCell") as! FilterCell
        cell.categoryLabel.text = category.name
        if let imageUrl = URL.init(string: category.imageUrl) {
            cell.filterImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "filterFood"))
        }
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryId = SharedObjects.shared.categories[indexPath.row].categoryId
        SharedObjects.shared.categoryId = categoryId
        
        self.dismiss(animated: true, completion: {})
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
