//
//  FlickrPhotosViewController.swift
//  CollectionViewExample
//
//  Created by Zaur Giyasov on 21/09/2018.
//  Copyright © 2018 Zaur Giyasov. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "FlickrCell"
fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
fileprivate var searches = [FlickrSearchResults]()
fileprivate let flickr = Flickr()
fileprivate let itemsPerRow: CGFloat = 2

class FlickrPhotosViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

private extension FlickrPhotosViewController {
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto {
        return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as IndexPath).row]
    }
}

extension FlickrPhotosViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!) { result, error in
            
            if let err = error {
                print("Search error: %@", err.localizedDescription)
                activityIndicator.stopAnimating()
                return
            }
            
            if let res = result {
                print("Found \(res.searchResults.count) matching \(res.searchTerm)")
                searches.insert(res, at: 0)
                
                self.collectionView.reloadData()
                activityIndicator.stopAnimating()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - UICollectionViewDataSource
extension FlickrPhotosViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCell
        cell.backgroundColor = UIColor.darkGray
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        cell.imageView.image = flickrPhoto.thumbnail
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader :
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FlickrPhotoHeaderView", for: indexPath) as! FlickrPhotoHeaderView
            headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpase = sectionInsets.left * (itemsPerRow + 1)
        let availableWith = view.frame.width - paddingSpase
        let widhtPerItem = availableWith / itemsPerRow
        
        return CGSize(width: widhtPerItem, height: widhtPerItem / 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: UICollectionViewDelegate
extension FlickrPhotosViewController {
    
}

