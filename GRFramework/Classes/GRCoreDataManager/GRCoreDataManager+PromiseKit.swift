//
//  GRCoreDataManager+PromiseKit.swift
//  GRFramework
//
//  Created by Gnatsel Revilo on 17/08/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit
extension GRCoreDataManager{
  /**
   * Fetch or Create an NSManagedObject fulfilling the given predicate
   *
   * @param entityName            The name of the entity to fetch
   * @param predicate       The predicate to fulfill
   * @param managedObjectContext  The NSManagedObjectContext where the fetch is performed
   *
   * @return an NSManagedObject fulfilling the given predicate
   */
  
  public class func managedObject(
    entityName entityName:String,
               predicate:NSPredicate?,
               managedObjectContext:NSManagedObjectContext) -> Promise<NSManagedObject>{
    return Promise { fulfill, reject in
      do {
        fulfill( try managedObject(entityName: entityName, predicate: predicate, managedObjectContext: managedObjectContext))
      }
      catch let error {
        reject(error)
      }
    }
  }
  
  /**
   * Fetch or Create an NSManagedObject fulfilling the given predicate
   *
   * @param entityName            The name of the entity to fetch
   * @param predicate       The predicate to fulfill
   * @param managedObjectContext  The NSManagedObjectContext where the fetch is performed
   *
   * @return an NSManagedObject fulfilling the given predicate
   */
  
  public class func managedObject<T:NSManagedObject>(
               predicate:NSPredicate?,
               managedObjectContext:NSManagedObjectContext) -> Promise<T>{
    return managedObject(entityClass: T.self, predicate: predicate, managedObjectContext: managedObjectContext).then{ (managedObject) -> Promise<T> in
      return Promise { fulfill, reject in

        guard let castedManagedObject = managedObject as? T else {
          reject(GRCoreDataManagerError.invalidEntityClass(entityClass: T.self))
          return
        }
        fulfill(castedManagedObject)
      }

    }
  }
  
  /**
   * Fetch or Create an NSManagedObject fulfilling the given predicate
   *
   * @param entityClass            The name of the entity to fetch
   * @param predicate       The predicate to fulfill
   * @param managedObjectContext  The NSManagedObjectContext where the fetch is performed
   *
   * @return an NSManagedObject fulfilling the given predicate
   */
  
  public class func managedObject(
    entityClass entityClass:AnyClass,
               predicate:NSPredicate?,
               managedObjectContext:NSManagedObjectContext) -> Promise<NSManagedObject>{
    return Promise { fulfill, reject in
      do {
        fulfill( try managedObject(entityClass: entityClass, predicate: predicate, managedObjectContext: managedObjectContext))
      }
      catch let error {
        reject(error)
      }
    }
  }
  

}
