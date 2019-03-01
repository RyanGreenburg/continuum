//
//  Post.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class Post: SearchableRecord {
    
    static let postTypeKey = "Post"
    fileprivate static let captionKey = "caption"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let commentsKey = "comments"
    fileprivate static let photoKey = "photo"
    
    var photoData: Data?
    let timestamp: Date
    var caption: String
    var comments: [Comment]
    var commentCount: Int
    var recordID: CKRecord.ID
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error writing to temp url \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = [], commentCount: Int = 0, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
    
    convenience init?(record: CKRecord) {
        guard let caption = record[Post.captionKey] as? String,
            let timestamp = record[Post.timestampKey] as? Date,
            let imageAsset = record[Post.photoKey] as? CKAsset
            else { return nil }
        
        guard let photoData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        guard let photo = UIImage(data: photoData) else { return nil }
        
        self.init(photo: photo, caption: caption, timestamp: timestamp, comments: [], commentCount: 0, recordID: record.recordID)
        
    }
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: Post.postTypeKey, recordID: post.recordID)
        
        self.setValue(post.caption, forKey: Post.captionKey)
        self.setValue(post.timestamp, forKey: Post.timestampKey)
        self.setValue(post.imageAsset, forKey: Post.photoKey)
    }
}

extension Post {
    func matches(searchTerm: String) -> Bool {
        if caption.contains(searchTerm) {
            return true
        }
        // Handle comments
        for comment in self.comments {
            if comment.matches(searchTerm: searchTerm) {
                return true
            }
        }
        return false
    }
}
