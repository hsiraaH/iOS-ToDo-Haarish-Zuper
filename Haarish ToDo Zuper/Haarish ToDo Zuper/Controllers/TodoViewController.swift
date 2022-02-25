//
//  ViewController.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 23/02/22.
//

import UIKit

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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showOverlay))
        
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
    
    @objc func showOverlay() {
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            self.present(slideVC, animated: true, completion: nil)
        }
        
    @IBAction func onButton(_ sender: Any) {
            showOverlay()
        }
    
    func getTodo() {
        let url = "http://167.71.235.242:3000/todo?_page=1&_limit=1500&author=Haarish"

        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

            guard let data = data, error == nil else {
                print("some error")
                return
            }
            
            do {
                self.todoList = try JSONDecoder().decode(TodoList.self, from: data)
                self.todoList?.data?.reverse()
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
    
    func updateCompleted(todo: Datum) {
        let tag = String(todo.tag!)
        let title = String(todo.title!)
        let priority = todo.priority?.rawValue
        let id = String(todo.id!)
        
        let putURL = URL(string: "http://167.71.235.242:3000/todo/\(id)")
        var request = URLRequest(url: putURL!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String : AnyHashable] = [
            "tag": tag,
            "title": title,
            "author": "Haarish",
            "is_Completed": "True",
            "priority": priority,
            "id": id
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in

            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }

            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(response)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            catch {
                print(error)
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
            if numOfItems < 15 {
                return numOfItems
            }
            return 15
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = todoList?.data![indexPath.row]
        
        
        if item?.isCompleted == nil || item?.isCompleted == false {
            updateCompleted(todo: item!)
        }
    }
}

extension TodoViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
