//
//  NoteMO+CoreDataClass.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/16/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//
//

import Foundation
import CoreData


public class NoteMO: NSManagedObject {
    
}

extension NoteMO {
    
    var model: NoteModel {
        return NoteModel(text: text, date: date as Date?)
    }
}
