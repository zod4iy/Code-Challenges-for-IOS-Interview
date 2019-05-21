//
//  UITableViewCell+Extension.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nibName: String {
        return String(describing: self)
    }
    
}
