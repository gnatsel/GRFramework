//
//  GRCoreDataManager+GRAppDelegate.swift
//  GRFramework
//
//  Created by Gnatsel Revilo on 17/08/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

import UIKit
import CoreData

public protocol GRAppDelegate {
  
  var managedObjectContext: NSManagedObjectContext { get set }
  func saveContext ()
}

extension GRCoreDataManager{
    
    /**
    * @return AppDelegate
    */
    
    public class func appDelegate() -> GRAppDelegate{
        return UIApplication.sharedApplication().delegate as! GRAppDelegate;
    }
    

  /**
   * @return managedObjectContext from GRAppDelegate
   */
  public class func managedObjectContext() -> NSManagedObjectContext{
    return appDelegate().managedObjectContext;
  }

}

