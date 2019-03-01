//
//  PostListTableViewController.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [Post] {
        return isSearching ? resultsArray : PostController.shared.posts
    }
    
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        resultsArray = PostController.shared.posts
        updateViews()
    }

    func updateViews() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.shared.fetchPosts { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell

        let post = resultsArray[indexPath.row]
        cell?.post = post

        return cell ?? UITableViewCell()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailVC" {
            guard let selectedRow = tableView.indexPathForSelectedRow?.row else { return }
            let post = PostController.shared.posts[selectedRow]
            let destinationVC = segue.destination as? PostDetailTableViewController
            destinationVC?.post = post
        }
    }
}

extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let posts = PostController.shared.posts
        
        if let searchTerm = searchBar.text, !searchTerm.isEmpty {
            resultsArray = posts.filter { post in
                return post.matches(searchTerm: searchTerm)
            }
        } else {
            resultsArray = posts
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let posts = PostController.shared.posts
        resultsArray = posts
        searchBar.text = ""
        resignFirstResponder()
        tableView.reloadData()
    }
}
