//
//  AddPostTableViewController.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UINavigationControllerDelegate, PhotoSelectorViewControllerDelegate {
    
    var photo: UIImage?
    
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let caption = captionTextField.text,
        let photo = photo else { return }
        PostController.shared.createPostWith(photo: photo, caption: caption) { (_) in
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 1
            }
        }
    }
    
    func photoSelectorViewControllerSelected(image: UIImage) {
        self.photo = image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSelectSegue" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
}
