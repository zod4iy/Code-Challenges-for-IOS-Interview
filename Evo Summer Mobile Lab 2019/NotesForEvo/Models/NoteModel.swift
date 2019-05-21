//
//  NoteModel.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import Foundation

private struct Constants {
    static let maxLength = 100
}

struct NoteModel {
    let text: String?
    let date: Date?
    
    var textFormated: String? {
        guard let text = text else { return nil }
        
        let formatedString = text.count <= Constants.maxLength
            ? text
            : "\(String(text.prefix(Constants.maxLength)))..."
        
        return formatedString
    }
    
    var dateFormated: String? {
        return date?.dateString
    }
    
    var timeFormated: String? {
        return date?.timeString
    }
}
