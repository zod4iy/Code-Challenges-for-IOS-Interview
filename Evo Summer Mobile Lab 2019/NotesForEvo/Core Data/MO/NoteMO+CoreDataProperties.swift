//
//  NoteMO+CoreDataProperties.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/16/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteMO> {
        return NSFetchRequest<NoteMO>(entityName: "Note")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?

}
