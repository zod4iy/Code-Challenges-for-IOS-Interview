//
//  NSManagedObjectContext+Extension.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    @discardableResult public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performSaveOrRollback() {
        perform {
            self.saveOrRollback()
        }
    }
}
