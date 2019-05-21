//
//  Date+Extension.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import Foundation

extension Date {
    
    var dateString: String {
        let formater = DateFormatter()
        formater.dateFormat = "dd.MM.yy"
        return formater.string(from: self)
    }
    
    var timeString: String {
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm"
        return formater.string(from: self)
    }
    
}
