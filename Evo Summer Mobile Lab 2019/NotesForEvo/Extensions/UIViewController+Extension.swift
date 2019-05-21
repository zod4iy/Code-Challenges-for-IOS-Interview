//
//  UIViewController+Extension.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static var storyboardName: String {
        return String(describing: self)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
