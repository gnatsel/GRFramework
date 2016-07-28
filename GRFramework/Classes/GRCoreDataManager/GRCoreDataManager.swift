//
//  GRCoreDataManager.swift
//  GRFramework
//
//  Created by Gnatsel Revilo on 14/08/2015.
//  Copyright (c) 2015 Gnatsel Reivilo. All rights reserved.
//

import UIKit
import CoreData

public enum GRCoreDataManagerError: ErrorType {
  case entityNameNotFound(entityName:String)
  case invalidEntityClass(entityClass:AnyClass)
}

public class GRCoreDataManager: NSObject {
  
  /**
   * Fetch or Create an NSManagedObject fulfilling the given predicate
   *
   * @param entityName            The name of the entity to fetch
   * @param predicateFormat       The predicate to fulfill
   * @param managedObjectContext  The NSManagedObjectContext where the fetch is performed
   *
   * @return an NSManagedObject fulfilling the given predicate
   */
  
  public class func managedObject(
               entityName entityName:String,
               predicate:NSPredicate?,
               managedObjectContext:NSManagedObjectContext) throws -> NSManagedObject{
    var managedObject:NSManagedObject!
    var shouldInstantiateNewManagedObject = true
    if let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext) {
      if let predicate = predicate {
        let request:NSFetchRequest = NSFetchRequest()
        request.entity = entityDescription
        request.predicate = predicate
        
        let managedObjectsArray = try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
        if managedObjectsArray.count > 0 {
            shouldInstantiateNewManagedObject = false
            managedObject = managedObjectsArray.first
          }
      }
      if shouldInstantiateNewManagedObject{
        managedObject = NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
      }
    }
    guard managedObject != nil else { throw GRCoreDataManagerError.entityNameNotFound(entityName: entityName) }
    return managedObject
  }
  
  public class func managedObject(
    entityClass entityClass:AnyClass,
    predicate:NSPredicate?,
    managedObjectContext:NSManagedObjectContext) throws -> NSManagedObject{
    return try managedObject(entityName: GRUtils.stringFromClass(entityClass), predicate: predicate, managedObjectContext: managedObjectContext)
  }
  
  
  /**
   * Instantiate and return an NSFetchedResultsController for an entity with the given name
   *
   * @param entityName            The name of the entity to fetch
   * @param delegate              The delegate of the NSFetchedResultsController
   * @param predicateFormat       The predicate format to fulfill
   * @param sortDescriptors       The array of descriptors for the NSFetchedResultsController
   * @param sectionNameKeyPath    The sectionNameKeyPath of the NSFetchedResultsController
   * @param managedObjectContext  The NSManagedObjectContext where NSManagedObjects are deleted
   *
   * @return an NSFetchedResultsController for the given managedObjectContext
   */
  
  public class func fetchedResultsController(entityName entityName:String,
                                                         delegate:NSFetchedResultsControllerDelegate?,
                                                         predicate:NSPredicate?,
                                                         sortDescriptors:[NSSortDescriptor],
                                                         sectionNameKeyPath:String?,
                                                         managedObjectContext:NSManagedObjectContext) throws -> NSFetchedResultsController{
    let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    let fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil);
    fetchedResultsController.delegate = delegate;
    try fetchedResultsController.performFetch()
   return fetchedResultsController
  }
  
  
  
  /**
   * Instantiate and return an NSFetchedResultsController for an entity with the given name
   *
   * @param entityName            The name of the entity to fetch
   * @param delegate              The delegate of the NSFetchedResultsController
   * @param predicateFormat       The predicate format to fulfill
   * @param sortDescriptors       The array of descriptors for the NSFetchedResultsController
   * @param sectionNameKeyPath    The sectionNameKeyPath of the NSFetchedResultsController
   * @param managedObjectContext  The NSManagedObjectContext where NSManagedObjects are deleted
   *
   * @return an NSFetchedResultsController for the given managedObjectContext
   */
  
  public class func fetchedResultsController(entityClass entityClass:AnyClass,
                                                        delegate:NSFetchedResultsControllerDelegate?,
                                                        predicate:NSPredicate?,
                                                        sortDescriptors:[NSSortDescriptor],
                                                        sectionNameKeyPath:String?,
                                                        managedObjectContext:NSManagedObjectContext) throws -> NSFetchedResultsController{
    return try fetchedResultsController(entityName:GRUtils.stringFromClass(entityClass),
                                          delegate:delegate,
                                         predicate:predicate,
                                   sortDescriptors:sortDescriptors,
                                sectionNameKeyPath:sectionNameKeyPath,
                              managedObjectContext:managedObjectContext)
  }
  
  
  public class func deleteManagedObjectsNotInArray<T:NSManagedObject>(managedObjectArray:[T], predicate:NSPredicate?, managedObjectContext:NSManagedObjectContext) throws {
    let entityName = GRUtils.stringFromClass(T.self)
    var predicates = [NSPredicate]()
    predicates.append(NSPredicate(format: "NOT (SELF IN $ARRAY)", managedObjectArray))
    if let predicate = predicate {
      predicates.append(predicate)
    }
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.predicate = compoundPredicate
    if #available(iOS 9.0, *) {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      try managedObjectContext.executeRequest(deleteRequest)
    } else {
      guard let managedObjectArrayToDelete = try managedObjectContext.executeFetchRequest(fetchRequest) as? [T] else { throw GRCoreDataManagerError.invalidEntityClass(entityClass: T.self) }
      for managedObject in managedObjectArrayToDelete {
        managedObjectContext.deleteObject(managedObjectContext.objectWithID(managedObject.objectID))
      }
    }
    if managedObjectContext.hasChanges { try managedObjectContext.save() }
  }
  

}