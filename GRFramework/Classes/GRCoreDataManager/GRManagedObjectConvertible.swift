//
//  GRManagedObjectConvertible.swift
//  Pods
//
//  Created by Gnatsel Reivilo on 22/07/2016.
//
//

import Foundation
import CoreData

public enum GRManagedObjectConvertibleError : ErrorType {
  case propertyNameNil(value:Any)
  case valueNotConvertible(propertyName:String, value:Any)
  case mismatchedEntityClass(entityClass:AnyClass, mappedEntityName:String)
}

public protocol GRManagedObjectConvertibleProperty {
  func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws
}

public protocol GRManagedObjectConvertible : GRBaseManagedObjectConvertible{
  typealias ManagedObjectClass:NSManagedObject

}

public extension GRManagedObjectConvertible {
  static var entityName : String {
    get {
      return GRUtils.stringFromClass(ManagedObjectClass)
    }
  }
  /*static func entityName() -> String {
    return GRUtils.stringFromClass(ManagedObjectClass)
  }*/
  func updatedManagedObject(managedObjectContext: NSManagedObjectContext) throws -> ManagedObjectClass {
    let managedObject = try _updatedManagedObject(managedObjectContext)
    guard let entity = managedObject as? ManagedObjectClass else {
      throw GRManagedObjectConvertibleError.mismatchedEntityClass(entityClass:ManagedObjectClass.self, mappedEntityName: Self.entityName)
    }
    return entity
  }
}

public protocol GRBaseManagedObjectConvertible : GRManagedObjectConvertibleProperty{

  static var entityName: String { get }
 // static func entityName() -> String
  func predicate() -> NSPredicate?
}

extension GRBaseManagedObjectConvertible {
  
  
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    try managedObject.setValue(_updatedManagedObject(managedObject.managedObjectContext!), forKeyPath: forKeyPath)
  }
  
  private func _updatedManagedObject(managedObjectContext:NSManagedObjectContext) throws -> NSManagedObject {
    let managedObject:NSManagedObject = try GRCoreDataManager.managedObject(entityName: Self.entityName, predicate: predicate(), managedObjectContext: managedObjectContext)
    let mirror = Mirror(reflecting: self)
    for (label, anyValue) in mirror.children {
      guard let propertyName = label  else {
        throw GRManagedObjectConvertibleError.propertyNameNil(value: anyValue)
      }
      if let managedObjectConvertible = anyValue as? GRManagedObjectConvertibleProperty{
        try managedObjectConvertible.updateManagedObject(managedObject, forKeyPath: propertyName)
      } else {
        // If this is a sequence type (optional or collection)
        // We have to have a look at the values to see if they conform to GRManagedObjectConvertible
        // The alternative, constraining the type checker a la (roughly)
        // extension Array<T where Generator.Element==GRManagedObjectConvertible> : GRManagedObjectConvertible
        // extension Optional<T where Generator.Element==GRManagedObjectConvertible> : GRManagedObjectConvertible
        // doesn't currently work with Swift 2
        let valueMirror: Mirror = Mirror(reflecting: anyValue)
        
        // We map the display style as well as the optional firt child,
        switch (valueMirror.displayStyle, valueMirror.children.first) {
        // Empty Optional
        case (.Optional?, nil):
          managedObject.setValue(nil, forKeyPath: propertyName)
        // Optional with Value
        case (.Optional?, let child?):
          managedObject.setValue(child.value as? AnyObject, forKey: propertyName)
        // A collection of objects
        case (.Collection?, _):
          var managedObjectSet = Set<NSManagedObject>()
          for (_, value) in valueMirror.children {
            if let managedObjectConvertible = value as? GRBaseManagedObjectConvertible {
              managedObjectSet.insert(try managedObjectConvertible._updatedManagedObject(managedObjectContext))
            }
          }
          managedObject.setValue(managedObjectSet, forKeyPath: propertyName)

          
        default:
          // If we end up here, we were unable to decode it
          throw GRManagedObjectConvertibleError.valueNotConvertible(propertyName:propertyName, value:anyValue)
        }
      }
    }
    return managedObject
  }
}


extension Int: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension Int16: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(NSNumber(short:self), forKeyPath: forKeyPath)
  }
}

extension Int32: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(NSNumber(int:self), forKeyPath: forKeyPath)
  }
}

extension Int64: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(NSNumber(longLong:self), forKeyPath: forKeyPath)
  }
}

extension Double: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(NSNumber(double:self), forKeyPath: forKeyPath)
  }
}

extension Float: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension Bool: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension String: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension NSData: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension NSDate: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

extension NSDecimalNumber: GRManagedObjectConvertibleProperty {
  public func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    managedObject.setValue(self, forKeyPath: forKeyPath)
  }
}

public extension GRManagedObjectConvertibleProperty where Self:RawRepresentable, Self.RawValue:GRManagedObjectConvertibleProperty {
  func updateManagedObject(managedObject: NSManagedObject, forKeyPath: String) throws {
    return try rawValue.updateManagedObject(managedObject, forKeyPath: forKeyPath)
  }
}