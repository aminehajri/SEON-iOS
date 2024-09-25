//
//  PhotoGalleryViewContoller.swift
//  DemoApp
//
//  Created by Amine Hajri
//

import UIKit

class PhotoGalleryViewContoller: UIViewController, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! PictureCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: "PictureCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
    }
}


