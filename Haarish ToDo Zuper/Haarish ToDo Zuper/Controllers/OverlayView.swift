//
//  OverlayView.swift
//  Haarish ToDo Zuper
//
//  Created by Haarish on 24/02/22.
//

import UIKit

class OverlayView: UIViewController {
    
    @IBOutlet weak var slideIdicator: UIView!
    @IBOutlet weak var taskTag: UITextField!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var todoName: String?
    var todoTag: String?
    var priority: String = "LOW"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @IBAction func priorityChanged(_ sender: Any) {
        switch prioritySegment.selectedSegmentIndex {
        case 0:
            priority = "LOW"
        case 1:
            priority = "MEDIUM"
        case 2:
            priority = "HIGH"
        default:
            break
        }
    }
    
    @IBAction func submitClick(_ sender: Any) {
        let taskPriority = priority
        
        if let taskName = taskName.text, let tag = taskTag.text {
            postTodo(todo: taskName, tag: tag, priority: taskPriority)
        }
    }
    
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    func postTodo(todo: String, tag: String, priority: String) {
        let postURL = URL(string: "http://167.71.235.242:3000/todo")

        var request = URLRequest(url: postURL!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String : AnyHashable] = [
            "title" : todo,
            "author" : "Haarish",
            "tag" : tag,
            "is_Completed" : false,
            "priority" : priority
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
            }
            catch {
                print(error)
            }
        })

        task.resume()
    }
}
