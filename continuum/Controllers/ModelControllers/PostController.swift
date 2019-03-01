//
//  PostController.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    static let shared = PostController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var posts: [Post] = []
    
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        post.commentCount += 1
        let newComment = Comment(text: text, post: post)
        let commentAsRecord = CKRecord(comment: newComment)
        let postAsRecord = CKRecord(post: post)
        let operation = CKModifyRecordsOperation(recordsToSave: [postAsRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        operation.completionBlock = {
            completion(newComment)
        }
        publicDB.add(operation)
        
        publicDB.save(commentAsRecord) { (record, error) in
            if let error = error {
                print("Error saving comment to CloudKt \(error.localizedDescription)")
                completion(nil)
            }
            post.comments.append(newComment)
            completion(newComment)
        }
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let newPost = Post(photo: photo, caption: caption)
        let postAsRecord = CKRecord(post: newPost)
        
        publicDB.save(postAsRecord) { (record, error) in
            if let error = error {
                print("Error saving to CloudKit \(error.localizedDescription)")
                completion(nil)
            }
            self.posts.append(newPost)
            completion(newPost)
        }
    }
    
    func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Post.postTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching posts from CloudKit \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = records else { return }
            let postsArray = records.compactMap { Post(record: $0)}
            
            self.posts = postsArray
            completion(postsArray)
        }
    }
    
    func fetchComponents(for post: Post, completion: @escaping ([Comment]?) -> Void) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [Comment.postReferenceKey, postReference])
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching comments for \(post) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = records else { return }
            let commentsArray = records.compactMap { Comment(record: $0, post: post)}
            post.comments = commentsArray
            completion(commentsArray)
        }
    }
}

extension UIViewController {
    func presentSimpleAlertWith(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message
            , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
