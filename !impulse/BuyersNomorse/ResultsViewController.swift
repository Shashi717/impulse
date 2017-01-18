//
//  ResultsViewController.swift
//  BuyersNomorse
//
//  Created by Sabrina Ip on 11/8/16.
//  Copyright © 2016 Sabrina, Shashi, Erica. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var priceFilterButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var minPrice: String?
    var maxPrice: String?
    var searchedItem = ""
    
    var endpoint: String {
        var filterCount = 0
        let keywordInput = self.searchedItem.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var webAddress = "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.12.0&SECURITY-APPNAME=SabrinaI-GroupPro-PRD-dbff3fe44-d9ad0129&RESPONSE-DATA-FORMAT=JSON&paginationInput.entriesPerPage=25&keywords=\(keywordInput)"
        if let maxPriceEntered = self.maxPrice {
            webAddress += "&itemFilter(\(filterCount)).name=MaxPrice&itemFilter(\(filterCount)).value=\(maxPriceEntered)"
            filterCount += 1
        }
        if let minPriceEntered = self.minPrice {
            webAddress += "&itemFilter(\(filterCount)).name=MinPrice&itemFilter(\(filterCount)).value=\(minPriceEntered)"
        }
        return webAddress
    }
    
    var itemSelected: SearchResults?
    var items: [SearchResults]?
    // var sortedItems: [SearchResults]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.45, green:0.82, blue:0.30, alpha:1.0)
        priceFilterButton.layer.cornerRadius = 5
        loadData()
    }
    
    
    /* New sort method below */
    //    func sortSmallestToLargest {
    //        let unsortedItems = SearchResults.getDataFromJson(data: validData)
    //        self.items = unsortedItems?.sorted { (a, b) -> Bool in
    //
    //            var isSmaller = false
    //            let aPrice: Double? = Double(a.currentPrice)
    //            let bPrice: Double? = Double(b.currentPrice)
    //
    //            if let aP = aPrice, let bP = bPrice {
    //                isSmaller = aP < bP
    //            }
    //            return isSmaller
    //        }
    //
    //    }
    
    func loadData() {
        APIRequestManager.manager.getData(endPoint: self.endpoint) { (data: Data?) in
            if  let validData = data {
                self.items = SearchResults.getDataFromJson(data: validData)
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
        print("The endpoint is currently \(self.endpoint)")
    }
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            sortSmallestToLargest()
        case 1:
            sortLargestToSmallest()
        default:
            break
        }
        self.tableView.reloadData()
    }
    @IBAction func minPriceChanged(_ sender: UITextField) {
    }
    @IBAction func maxPriceChanged(_ sender: UITextField) {
    }
   
    
    func sortSmallestToLargest() {
        self.items = items?.sorted(by: { (a, b) -> Bool in
            guard let aPrice = Double(a.currentPrice),
                let bPrice = Double(b.currentPrice) else { return true }
            return aPrice < bPrice
        })
    }
    
    func sortLargestToSmallest() {
        self.items = items?.sorted(by: { (a, b) -> Bool in
            guard let aPrice = Double(a.currentPrice),
                let bPrice = Double(b.currentPrice) else { return true }
            return aPrice > bPrice
        })
    }
    
    
    func minMaxAreAcceptableAnswers() -> Bool {
        var minPDouble: Double?
        var maxPDouble: Double?
        
        minPrice = nil
        maxPrice = nil
        
        if minPriceTextField.text! != "" {
            guard let minNum = Double(minPriceTextField.text!), minNum > 0 else {
                errorLabel.isHidden = false
                errorLabel.text = "The minimum price is not a valid answer"
                return false
            }
            minPDouble = minNum
            minPrice = String(minNum)
        }
        
        if maxPriceTextField.text! != "" {
            guard let maxNum = Double(maxPriceTextField.text!), maxNum > 0 else {
                errorLabel.isHidden = false
                errorLabel.text = "The maximum price is not a valid answer"
                return false
            }
            maxPDouble = maxNum
            maxPrice = String(maxNum)
        }
        
        if let minExists = minPDouble, let maxExists = maxPDouble {
            guard minExists < maxExists else {
                errorLabel.text = "Minimum should be less than Maximum"
                return false
            }
        }
        
        errorLabel.text = nil
        errorLabel.isHidden = true
        return true
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        guard minMaxAreAcceptableAnswers() else {
            return
        }
        loadData()
        
    }
    
    // MARK: - TABLEVIEW
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let itemsExists = items else { return 0 }
        return itemsExists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! ResultsTableViewCell
        guard let itemsExists = items else { return cell }
        let item = itemsExists[indexPath.row]
        
        cell.itemTitleLabel.text = item.title
        
        //Trying to format the price into US Currency format
        //Source (Lines 194-200): http://stackoverflow.com/questions/39458003/swift-3-and-numberformatter-currency-
        let currentPrice = NSDecimalNumber(string: item.currentPrice)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_us")
        if let result = numberFormatter.string(from: currentPrice) {
            cell.itemPriceLabel.text = result
        }
    
        //Loads Image Async
        if let image = item.galleryUrl {
            APIRequestManager.manager.getData(endPoint: image) { (data: Data?) in
                if  let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        cell.itemImageView.image = validImage
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        
        return cell
    }
    
    //Deselects selected row after return from Alternative Choices View Controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "SegueToAlternativeViewController",
            let cell = sender as? ResultsTableViewCell,
            let destinationVC = segue.destination as? AlternativeChoicesViewController,
            let indexPath = self.tableView.indexPath(for: cell),
            let itemSelected = self.items?[indexPath.row] else {
                return
        }
        destinationVC.customerSelection = itemSelected
        
        //Trying to format the price into US Currency format
        //Source (Lines 239-245): http://stackoverflow.com/questions/39458003/swift-3-and-numberformatter-currency-
        let currentPrice = NSDecimalNumber(string: itemSelected.currentPrice)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_us")
        if let result = numberFormatter.string(from: currentPrice) {
            destinationVC.alternativeItemHeaderText = "Other Items @ \(result)"
        }
        
        destinationVC.alternativeItemImageURLString = itemSelected.viewItemUrl
        if let image = itemSelected.galleryUrl {
            APIRequestManager.manager.getData(endPoint: image) { (data: Data?) in
                if  let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        
                        destinationVC.chosenImageView.image = validImage
                        cell.setNeedsLayout()
                    }
                }
            }
            print("The image selected is \(image)")
        }
    }
}
