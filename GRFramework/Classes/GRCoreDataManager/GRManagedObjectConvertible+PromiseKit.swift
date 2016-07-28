//
//  GRManagedObjectConvertible+PromiseKit.swift
//  Pods
//
//  Created by Olivier Lestang on 22/07/2016.
//
//

import Foundation
import PromiseKit
import CoreData
public extension GRManagedObjectConvertible {
  /*func updatedManagedObjectPromise(managedObjectContext:NSManagedObjectContext) -> Promise<NSManagedObject> {
    return Promise { fulfill, reject in
      do {
        fulfill(try updatedManagedObject(managedObjectContext))
      } catch let error {
        reject(error)
      }
    }
  }*/
  
  func updatedManagedObjectPromise(managedObjectContext:NSManagedObjectContext) -> Promise<ManagedObjectClass> {
    return Promise { fulfill, reject in
      do {
        guard let managedObject = try updatedManagedObject(managedObjectContext) as? ManagedObjectClass else {
          reject(GRManagedObjectConvertibleError.mismatchedEntityClass(entityClass: ManagedObjectClass.self, mappedEntityName: Self.entityName))
          return
        }
        fulfill(managedObject)
      } catch let error {
        reject(error)
      }
    }
  }
}