//
//  AlternativePopoverViewController.swift
//  BuyersNomorse
//
//  Created by Madushani Lekam Wasam Liyanage on 11/10/16.
//  Copyright © 2016 Sabrina, Shashi, Erica. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit

class AlternativePopoverViewController: UIViewController, UIPopoverControllerDelegate {
    
    @IBOutlet weak var alternativeImageButton: UIButton!
    
    @IBOutlet weak var alternativeItemNameLabel: UILabel!
    @IBOutlet weak var alternativeItemPriceLabel: UILabel!
    
    @IBOutlet weak var alternativeCategoryLabel: UILabel!
    var itemImage: String?
    
  
    @IBOutlet weak var alternativeImageView: UIImageView!
    
    var alternativeItem: SearchResults?
  
    
    @IBAction func alternativeImageButtonTapped(_ sender: UIButton) {
        if let alternativeItemURL = URL(string: (alternativeItem?.viewItemUrl)!) {
            UIApplication.shared.open(alternativeItemURL)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        alternativeItemNameLabel.text = alternativeItem?.title
        alternativeCategoryLabel.text = "Category: \((alternativeItem?.categoryName)!)"
        
        if let itemPrice = alternativeItem?.currentPrice {
            //Returns properly formatted currency
            let currentPrice = NSDecimalNumber(string: itemPrice)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale(identifier: "en_us")
            if let result = numberFormatter.string(from: currentPrice) {
                alternativeItemPriceLabel.text = result
            }
        }
        
      guard let alternativeItemsExists = alternativeItem else { return }
        
        if let plusImage = alternativeItemsExists.galleryPlusPictureUrl {
            itemImage = plusImage
            
        }
        else if let smallImage = alternativeItem?.galleryUrl {
            itemImage = smallImage
        }
        
        if let image = itemImage {
            APIRequestManager.manager.getData(endPoint: image) { (data: Data?) in
                if  let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        self.alternativeImageView.image = validImage
                    }
                }
                
            }
        }
        
        
        //http://studyswift.blogspot.com/2016/01/facebook-sdk-and-swift-post-message-and.html
        //Creates share button
        
        let urlImage = NSURL(string: (self.alternativeItem?.galleryUrl)!)
        
        let content = FBSDKShareLinkContent()
        content.contentTitle = alternativeItem?.title
        content.imageURL = urlImage as URL!
        
        let shareButton = FBSDKShareButton()
        shareButton.center = CGPoint(x: view.center.x - 120, y: view.center.y + 8)
        shareButton.shareContent = content
        view.addSubview(shareButton)
        
        //Creates Facebook Like Button
        let likeButton = FBSDKLikeControl()
        likeButton.objectID = alternativeItemsExists.viewItemUrl
        likeButton.likeControlStyle = .boxCount
        likeButton.center = CGPoint(x: view.center.x - 40, y: view.center.y + 8)
        self.view.addSubview(likeButton)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func prepareForReuse() {
        //self.imageButton.imageView?.image = nil
    }
    
    
}
