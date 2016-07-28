//
//  ViewController.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 06/22/2016.
//  Copyright (c) 2016 Gnatsel Reivilo. All rights reserved.
//

import UIKit
import GRFramework
import Argo
import Curry
import CoreData
import PromiseKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let productsPromise:Promise<[ProductConvertible]> = ProductApiManager().performRequest()
    productsPromise.then { (products) -> Promise<[Product]> in
      return when(products.map{ (product) -> Promise<Product> in
        return product.updatedManagedObjectPromise(GRCoreDataManager.managedObjectContext())
      })
      }.then{ (products) -> Void in
        print(products)
      }.error { (error) in
        print(error)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

class ProductApiManager : GRApiManager {
  
  required init(){
    super.init()
    url = "http://localhost:8888/products.json"
  }
  
  
}

struct CategoryConvertible : GRManagedObjectConvertible {
  typealias ManagedObjectClass = Category
  
  var categoryId: Int
  var categoryName: String
  
  func predicate() -> NSPredicate? {
    return NSPredicate(format: "categoryId = %d", argumentArray: [categoryId])
  }
  
}

extension CategoryConvertible: Decodable {
  static  func decode(j: JSON) -> Decoded<CategoryConvertible> {
    return curry(CategoryConvertible.init)
      <^> j <| "categoryId"
      <*> j <| "categoryName"
  }
}
struct ProductConvertible: GRManagedObjectConvertible {
  
  typealias ManagedObjectClass = Product
  var productId:Int
  var productName:String
  var categories:[CategoryConvertible]
  
  func predicate() -> NSPredicate? {
    return NSPredicate(format: "productId = %d", argumentArray: [productId])
  }
}

extension ProductConvertible: Decodable {
  static  func decode(j: JSON) -> Decoded<ProductConvertible> {
    return curry(ProductConvertible.init)
      <^> j <| "productId"
      <*> j <| "productName"
      <*> j <|| "categories"
  }
}