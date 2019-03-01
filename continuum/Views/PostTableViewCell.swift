//
//  PostTableViewCell.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    
    func updateViews() {
        guard let post = post else { return }
        postImageView.image = post.photo
        captionLabel.text = post.caption
        commentCountLabel.text = "\(post.comments.count)"
    }
}
