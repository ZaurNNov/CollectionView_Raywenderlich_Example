//
//  FlickrPhotoCell.swift
//  CollectionViewExample
//
//  Created by Zaur Giyasov on 21/09/2018.
//  Copyright © 2018 Zaur Giyasov. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }
    
    // MARK: - View Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
    
}
