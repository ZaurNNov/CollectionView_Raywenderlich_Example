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

    fileprivate var largePhotoIndexPath: NSIndexPath? {
        didSet {
            var indexPaths = [IndexPath]()
            if let largePhoto = largePhotoIndexPath {
                indexPaths.append(largePhoto as IndexPath)
            }
            
            if let old = oldValue {
                indexPaths.append(old as IndexPath)
            }
            
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPaths)
            }) { completed in
                
                if let largePhotoIndex = self.largePhotoIndexPath {
                    self.collectionView.scrollToItem(
                        at: largePhotoIndex as IndexPath,
                        at: .centeredVertically,
                        animated: true)
                }
            }
        }
    }
    
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
        cell.activityIndicator.stopAnimating()
        
        guard (indexPath as NSIndexPath) == largePhotoIndexPath else {
            cell.imageView.image = flickrPhoto.thumbnail
            return cell
        }
        
        guard flickrPhoto.largeImage == nil else {
            cell.imageView.image = flickrPhoto.largeImage
            return cell
        }
        
        cell.imageView.image = flickrPhoto.thumbnail
        cell.activityIndicator.startAnimating()
        
        flickrPhoto.loadLargeImage { loaded, error in
            
            cell.activityIndicator.stopAnimating()
            
            guard loaded.largeImage != nil && error == nil else {
                return
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? FlickrPhotoCell,
                (indexPath as NSIndexPath) == self.largePhotoIndexPath {
                cell.imageView.image = loaded.largeImage
            }
        }
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
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        largePhotoIndexPath = largePhotoIndexPath == (indexPath as NSIndexPath) ? nil : indexPath as NSIndexPath
        return false
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (indexPath as NSIndexPath) == largePhotoIndexPath {
            let flickrPhoto = photoForIndexPath(indexPath: indexPath)
            var size = collectionView.bounds.size
            size.height -= topLayoutGuide.length
            size.height -= (sectionInsets.top + sectionInsets.right)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidthOfSize(size)
        }
        
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
