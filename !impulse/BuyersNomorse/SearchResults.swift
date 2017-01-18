//
//  SearchResult.swift
//  BuyersNomorse
//
//  Created by Sabrina Ip on 11/8/16.
//  Copyright © 2016 Sabrina, Shashi, Erica. All rights reserved.
//

import Foundation

internal enum jsonSerialization: Error {
    case response(jsonData: Any)
    case findItemsAdvancedResponse(response: [String: Any])
    case theResults(findItemsAdvancedResponse: [[String : Any]])
    case item(theResults: [[String : Any]])
}

internal enum searchResultParseError: Error {
    case titleArr(itemObject: Dictionary<String, Any>)
    case title(titleArr: [Any])
    case primaryCategory(itemObject: Dictionary<String, Any>)
    case categoryIdArr(primaryCategory: [[String : Any]])
    case categoryId(categoryIdArr: [Any])
    case categoryNameArr(primaryCategory: [[String : Any]])
    case categoryName(categoryNameArr: [Any])
    case viewItemURLArr(itemObject: Dictionary<String, Any>)
    case viewItemUrl(viewItemURLArr: [Any])
    case sellingStatus(itemObject: Dictionary<String, Any>)
    case convertedPrice(sellingStatus: [[String : Any]])
    case currentPrice(convertedPrice: [[String : String]])
}

//"galleryPlusPictureURL": [
//"http://galleryplus.ebayimg.com/ws/web/182190036074_1_3_1_00000003.jpg"
//]

class SearchResults {
    let title: String
    let galleryUrl: String?
    let viewItemUrl: String
    let currentPrice: String
    let categoryId: String
    let categoryName: String
    let galleryPlusPictureUrl: String?
    
    init(title: String, galleryUrl: String?, viewItemUrl: String, currentPrice: String, categoryId: String, categoryName: String, galleryPlusPictureUrl: String?) {
        self.title = title
        self.galleryUrl = galleryUrl
        self.viewItemUrl = viewItemUrl
        self.currentPrice = currentPrice
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.galleryPlusPictureUrl = galleryPlusPictureUrl
    }
    
    static func getDataFromJson(data: Data) -> [SearchResults]? {
        var searchResults = [SearchResults]()
        
        do {
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            
            guard let response = jsonData as? [String: Any] else {
                throw jsonSerialization.response(jsonData: jsonData as Any)
            }
            guard let findItemsAdvancedResponse = response["findItemsAdvancedResponse"] as? [[String: Any]] else {
                throw jsonSerialization.findItemsAdvancedResponse(response: response)
            }
            guard let theResults = findItemsAdvancedResponse[0]["searchResult"] as? [[String:Any]] else {
                throw jsonSerialization.theResults(findItemsAdvancedResponse: findItemsAdvancedResponse)
            }
            
            guard let item = theResults[0]["item"] as? [[String: Any]] else {
                throw jsonSerialization.item(theResults: theResults)
            }
            
            for itemObject in item {
                guard let titleArr = itemObject["title"] as? [Any] else {
                    throw searchResultParseError.titleArr(itemObject: itemObject)
                }
                guard let title = titleArr[0] as? String else {
                    throw searchResultParseError.title(titleArr: titleArr)
                }
                
                guard let primaryCategory = itemObject["primaryCategory"] as? [[String: Any]] else {
                    throw searchResultParseError.primaryCategory(itemObject: itemObject)
                }
                guard let categoryIdArr = primaryCategory[0]["categoryId"] as? [Any] else {
                    throw searchResultParseError.categoryIdArr(primaryCategory: primaryCategory)
                }
                guard let categoryId = categoryIdArr[0] as? String else {
                    throw searchResultParseError.categoryId(categoryIdArr: categoryIdArr)
                }
                    
                guard let categoryNameArr = primaryCategory[0]["categoryName"] as? [Any] else {
                    throw searchResultParseError.categoryNameArr(primaryCategory: primaryCategory)
                }
                guard let categoryName = categoryNameArr[0] as? String else {
                    throw searchResultParseError.categoryName(categoryNameArr: categoryNameArr)
                }
                    

                    
                guard let viewItemURLArr = itemObject["viewItemURL"] as? [Any] else {
                    throw searchResultParseError.viewItemURLArr(itemObject: itemObject)
                }
                guard let viewItemUrl = viewItemURLArr[0] as? String else {
                    throw searchResultParseError.viewItemUrl(viewItemURLArr: viewItemURLArr)
                }
                    
                guard let sellingStatus = itemObject["sellingStatus"] as? [[String:Any]] else {
                    throw searchResultParseError.sellingStatus(itemObject: itemObject)
                }
                guard let convertedPrice = sellingStatus[0]["convertedCurrentPrice"] as? [[String:String]] else {
                    throw searchResultParseError.convertedPrice(sellingStatus: sellingStatus)
                }
                guard let currentPrice = convertedPrice[0]["__value__"] else {
                    throw searchResultParseError.currentPrice(convertedPrice: convertedPrice)
                }
                
                var galleryUrl: String?
                var galleryPlusPictureUrl: String?
                
                if let galleryUrlArr = itemObject["galleryURL"] as? [Any] {
                    galleryUrl = galleryUrlArr[0] as? String
                }
                if let galleryPlusPictureUrlArr = itemObject["galleryPlusPictureURL"] as? [Any] {
                    galleryPlusPictureUrl = galleryPlusPictureUrlArr[0] as? String
                }
                
                let sr = SearchResults(title: title, galleryUrl: galleryUrl, viewItemUrl: viewItemUrl, currentPrice: currentPrice, categoryId: categoryId, categoryName: categoryName, galleryPlusPictureUrl: galleryPlusPictureUrl)
                searchResults.append(sr)
            }
        } catch let jsonSerialization.response(jsonData: jsonData) {
            print("RESPONSE PARSE ERROR - jsonData: \(jsonData)")
        } catch let jsonSerialization.findItemsAdvancedResponse(response: response) {
            print("FIND_ITEMS_ADVANCED_RESPONSE PARSE ERROR - response: \(response)")
        } catch let jsonSerialization.theResults(findItemsAdvancedResponse: findItemsAdvancedResponse) {
            print("THE_RESULTS PARSE ERROR - findItemsAdvancedResponse: \(findItemsAdvancedResponse)")
        } catch let jsonSerialization.item(theResults: theResults) {
            print("ITEM PARSE ERROR - theResults: \(theResults)")
        } catch let searchResultParseError.titleArr(itemObject: itemObject) {
            print("TITLE_ARR PARSE ERROR - itemObject: \(itemObject)")
        } catch let searchResultParseError.title(titleArr: titleArr) {
            print("TITLE PARSE ERROR - titleArr: \(titleArr)")
        } catch let searchResultParseError.primaryCategory(itemObject: itemObject) {
            print("PRIMARY_CATEGORY PARSE ERROR - itemObject: \(itemObject)")
        } catch let searchResultParseError.categoryIdArr(primaryCategory: primaryCategory) {
            print("CATEGORY_ID_ARR PARSE ERROR - primaryCategory: \(primaryCategory)")
        } catch let searchResultParseError.categoryId(categoryIdArr: categoryIdArr) {
            print("CATEGOY_ID PARSE ERROR - categoryIdArr: \(categoryIdArr)")
        } catch let searchResultParseError.categoryNameArr(primaryCategory: primaryCategory) {
            print("CATEGORY_NAME_ARR PARSE ERROR - primaryCategory : \(primaryCategory)")
        } catch let searchResultParseError.categoryName(categoryNameArr: categoryNameArr) {
            print("CATEGORY_NAME PARSE ERROR - categoryNameArr: \(categoryNameArr)")
        } catch let searchResultParseError.viewItemURLArr(itemObject: itemObject) {
            print("VIEW_ITEM_URL_ARR PARSE ERROR - itemObject: \(itemObject)")
        } catch let searchResultParseError.viewItemUrl(viewItemURLArr: viewItemURLArr) {
            print("VIEW_ITEM_URL PARSE ERROR - viewItemURLArr: \(viewItemURLArr)")
        } catch let searchResultParseError.sellingStatus(itemObject: itemObject) {
            print("SELLING_STATUS PARSE ERROR - itemObject: \(itemObject)")
        } catch let searchResultParseError.convertedPrice(sellingStatus: sellingStatus) {
            print("CONVERTED_PRICE PARSE ERROR - sellingStatus: \(sellingStatus)")
        } catch let searchResultParseError.currentPrice(convertedPrice: convertedPrice) {
            print("CURRENT_PRICE PARSE ERROR - convertedPrice: \(convertedPrice)")
        } catch {
            print(error)
        }
        
        return searchResults
    }
}
