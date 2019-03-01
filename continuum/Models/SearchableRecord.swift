//
//  SearchableRecord.swift
//  continuum
//
//  Created by RYAN GREENBURG on 2/27/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
