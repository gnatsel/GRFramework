//
//  Category+CoreDataProperties.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 20/07/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var categoryId: NSNumber?
    @NSManaged var categoryName: String?
    @NSManaged var products: NSSet?

}
