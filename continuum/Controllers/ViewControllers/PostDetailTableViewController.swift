//
//  PostDetailTableViewController.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var postImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateViews() {
        guard let post = post else { return }
        DispatchQueue.main.async {
            self.postImageView.image = post.photo
            self.tableView.reloadData()
        }
    }

    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        var commentTextField: UITextField?
        let commentAlertController = UIAlertController(title: "New Comment", message: "Say someting cool!", preferredStyle: .alert)
        commentAlertController.addTextField { (textField) in
            textField.placeholder = "Your comment here..."
            commentTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.tableView.reloadData()
        }
        
        let addAction = UIAlertAction(title: "Comment", style: .default) { (_) in
            guard let comment = commentTextField?.text, !comment.isEmpty,
                let post = self.post else { return }
            PostController.shared.addComment(text: comment, post: post, completion: { (comment) in
                if let comment = comment {
                    post.comments.append(comment)
                    self.updateViews()
                }
            })
        }
        commentAlertController.addAction(addAction)
        commentAlertController.addAction(cancelAction)
        
        present(commentAlertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
//        guard let post = post else { return }
//        let activityItems: [Any] = [post.photo, post.caption]
//        let applicationActivities = UIActivity.ActivityType.
//        UIActivityViewController(activityItems: [post.photo, post.caption], applicationActivities: [])
//
//        PostController.shared.createPostWith(photo: <#T##UIImage#>, caption: <#T##String#>, completion: <#T##(Post?) -> Void#>)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
        return post.comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        guard let comment = post?.comments[indexPath.row] else { return cell }
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = "\(comment.timestamp)"

        return cell
    }
}


