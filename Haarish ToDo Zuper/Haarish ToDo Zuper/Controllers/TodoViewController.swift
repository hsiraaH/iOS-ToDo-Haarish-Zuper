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
            borderView.layer.borderWidth = 1
            borderView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var tickCircle: UIView! {
        didSet {
            tickCircle.layer.borderWidth = 1
            tickCircle.layer.borderColor = UIColor.systemGray4.cgColor
            tickCircle.layer.cornerRadius = tickCircle.frame.height / 2
            tickCircle.layer.shouldRasterize = true
        }
    }
    @IBOutlet weak var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 1
            tagLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var priorityCircle: UIView! {
        didSet {
            priorityCircle.layer.cornerRadius = priorityCircle.frame.height / 2
            priorityCircle.layer.shouldRasterize = true
        }
    }
    let identifier = "TodoCell"
    
    func setData(priority: String?, todo: String?, tag: String?, isCompleted: Bool?) {
        contentLabel.text = todo ?? ""
        tagLabel.text = tag ?? ""
        
        if isCompleted == false || isCompleted == nil {
            tickCircle.backgroundColor = UIColor.clear
            tickImage.isHidden = true
        }
        
        switch(priority) {
        case "LOW":
            priorityCircle.backgroundColor = UIColor.green
        
        case "MEDIUM":
            priorityCircle.backgroundColor = UIColor.yellow
            
        case "HIGH":
            priorityCircle.backgroundColor = UIColor.red
            
        default:
            priorityCircle.backgroundColor = UIColor.clear
        }
    }
}

class TodoViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.backgroundImage = UIImage()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var todoList: TodoList?
    
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
        
        getTodo()
        
        if #available(iOS 13.0, *){
            collectionView.collectionViewLayout = createCompositionalLayout()
        }
        else {
            
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func getTodo() {
        let url = "http://167.71.235.242:3000/todo?_page=1&_limit=15&author=Haarish"

        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

            guard let data = data, error == nil else {
                print("some error")
                return
            }
            
            do {
                self.todoList = try JSONDecoder().decode(TodoList.self, from: data)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            catch {
                print("failed to convert resonse, \(error.localizedDescription)")
            }
            
        })
        task.resume()
    }
    
    @available(iOS 13.0, *)
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                group.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10)
            
                let section = NSCollectionLayoutSection(group: group)
                return section
        }
        return layout
    }

}

extension TodoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfItems = todoList?.totalRecords {
            return numOfItems
        }
        
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = todoList?.data![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCell().identifier, for: indexPath) as! TodoCell
        
        cell.setData(priority: item?.priority?.rawValue, todo: item?.title, tag: item?.tag, isCompleted: item?.isCompleted)
        
        return cell
    }
}
