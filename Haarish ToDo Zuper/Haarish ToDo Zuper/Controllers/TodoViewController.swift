//
//  ViewController.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 23/02/22.
//

import UIKit

class TodoCell: UICollectionViewCell {
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var tickCircle: UIView! {
        didSet {
            tickCircle.layer.cornerRadius = tickCircle.frame.height / 2
            tickCircle.layer.shouldRasterize = true
        }
    }
    @IBOutlet weak var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 6
            tagLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var priorityCircle: UIView!
    let identifier = "TodoCell"
}

class TodoViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.backgroundImage = UIImage()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Todo"
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.systemGray6
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        if #available(iOS 13.0, *){
            collectionView.collectionViewLayout = createCompositionalLayout()
        }
        else {
            
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @available(iOS 13.0, *)
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                return section
        }
        return layout
    }

}

extension TodoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
}
