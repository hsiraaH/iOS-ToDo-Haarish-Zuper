//
//  TagViewController.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 24/02/22.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var tagName: UILabel! {
        didSet {
            tagName.layer.cornerRadius = 1
            tagName.layer.masksToBounds = true
        }
    }
    let identifier = "SectionHeader"
}

class TagCell: UICollectionViewCell {
    @IBOutlet weak var priorityCircle: UIView! {
        didSet {
            priorityCircle.layer.cornerRadius = priorityCircle.frame.height / 2
            priorityCircle.layer.shouldRasterize = true
        }
    }
    @IBOutlet weak var todo: UILabel!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 10
            borderView.layer.borderWidth = 1
            borderView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    
    let identifier = "TagCell"
    
    func setData(todoTask: String, priority: String) {
        todo.text = todoTask
        
        switch(priority) {
        case "LOW":
            priorityCircle.backgroundColor = UIColor.green
        
        case "MEDIUM":
            priorityCircle.backgroundColor = UIColor.orange
            
        case "HIGH":
            priorityCircle.backgroundColor = UIColor.red
            
        default:
            priorityCircle.backgroundColor = UIColor.clear
        }
    }
}

class TagViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.backgroundImage = UIImage()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var iosTodo: TodoList?
    var backendTodo: TodoList?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tags"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showOverlay))
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.systemGray6
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        getTodoWithTag(tag: "iOS")
        getTodoWithTag(tag: "Backend")
        
        if #available(iOS 13.0, *){
            collectionView.collectionViewLayout = createCompositionalLayout()
        }
        else {
            
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func showOverlay() {
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            self.present(slideVC, animated: true, completion: nil)
        }
        
    @IBAction func onButton(_ sender: Any) {
            showOverlay()
        }
    
    @available(iOS 13.0, *)
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                group.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
                let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
                return section
        }
        return layout
    }
    
    func getTodoWithTag(tag: String) {
        let url = "http://167.71.235.242:3000/todo?_page=1&_limit=1500&author=Haarish&tag=\(tag)"

        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

            guard let data = data, error == nil else {
                print("some error")
                return
            }
            
            do {
                if tag == "iOS" {
                    self.iosTodo = try JSONDecoder().decode(TodoList.self, from: data)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                else {
                    self.backendTodo = try JSONDecoder().decode(TodoList.self, from: data)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }
            catch {
                print("failed to convert resonse, \(error.localizedDescription)")
            }
            
        })
        task.resume()
    }

}

extension TagViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let numOfItems = iosTodo?.totalRecords {
                return numOfItems
            }
            return 0
        case 1:
            if let numOfItems = backendTodo?.totalRecords {
                return numOfItems
            }
            return 0
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell().identifier, for: indexPath) as! TagCell
        switch indexPath.section {
        case 0:
            let item = iosTodo?.data![indexPath.item]
            cell.setData(todoTask: (item?.title!)!, priority: (item?.priority!.rawValue)!)
        case 1:
            let item = backendTodo?.data![indexPath.item]
            cell.setData(todoTask: (item?.title!)!, priority: (item?.priority!.rawValue)!)
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader().identifier, for: indexPath) as! SectionHeader
        
        switch indexPath.section {
        case 0:
            sectionHeader.tagName.text = "iOS"
        case 1:
            sectionHeader.tagName.text = "Backend"
        default:
            break
        }
        return sectionHeader
    }
}


extension TagViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
