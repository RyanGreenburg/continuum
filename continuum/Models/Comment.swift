//
//  Comment.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if text.contains(searchTerm) {
            return true
        } else {
            return false
        }
    }
    
    static let commentTypeKey = "Comment"
    fileprivate static let textKey = "text"
    fileprivate static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
    
    
    let text: String
    let timestamp: Date
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    weak var post: Post?
    
    init(text: String, timestamp: Date = Date(), post: Post, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
    
    convenience init?(record: CKRecord, post: Post) {
        guard let text = record[Comment.textKey] as? String,
            let timestamp = record[Comment.timestampKey] as? Date
            else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: post, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: Comment.commentTypeKey, recordID: comment.recordID)
        
        self.setValue(comment.text, forKey: Comment.textKey)
        self.setValue(comment.timestamp, forKey: Comment.timestampKey)
        self.setValue(comment.postReference, forKey: Comment.postReferenceKey)
    }
}
