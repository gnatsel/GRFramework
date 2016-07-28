//
//  GRUtils.swift
//  GRFramework
//
//  Created by Gnatsel Revilo on 14/08/2015.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Gnatsel Reivilo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import UIKit

public class GRUtils : NSObject {
  public static let mainBundle:NSBundle = NSBundle.mainBundle()
  public static let fileManager:NSFileManager = NSFileManager.defaultManager()
  public static let plistType = "plist"
  public static let jsonType = "json"
  public static let standardUserDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
  public static var appVersion:String {
    get{
      return mainBundle.infoDictionary!["CFBundleShortVersionString"] as! String + " (Build " + (mainBundle.infoDictionary![kCFBundleVersionKey as String] as! String) + ")"

    }
  }
  public static func cachesDirectory() -> String {
    var cachesDirectory:String = "" ;
    if let directories:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,
                                                                      NSSearchPathDomainMask.UserDomainMask,
                                                                      true) {
      cachesDirectory = directories[0]
    }
    
    return cachesDirectory
  }
  
  
  public static func objectFromPlistNamed(plistName:String) -> AnyObject? {
    return GRUtils.objectFromPlistNamed(plistName, bundle: GRUtils.mainBundle)
  }
  
  public static func objectFromPlistNamed(plistName:String, bundle:NSBundle) -> AnyObject? {
    guard let plistData = GRUtils.fileManager.contentsAtPath(bundle.pathForResource(plistName, ofType: GRUtils.plistType)!) else { return nil }
    do {
      return try NSPropertyListSerialization.propertyListWithData(plistData, options: NSPropertyListMutabilityOptions.Immutable, format: nil)
    }
    catch let error as NSError {
      print("error \(error)\n\(error.userInfo)")
    }
    return nil
  }
  public static func objectFromJson(jsonName:String) -> AnyObject? {
    return GRUtils.objectFromJson(jsonName, bundle: GRUtils.mainBundle)
  }
  public static func objectFromJson(jsonName:String, bundle:NSBundle) -> AnyObject? {
    guard let jsonData = GRUtils.fileManager.contentsAtPath(GRUtils.mainBundle.pathForResource(jsonName, ofType: GRUtils.jsonType)!) else { return nil }
    do {
      return try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
    }
    catch let error as NSError {
      print("error \(error)\n\(error.userInfo)")
    }
    return nil
  }
  
  public static func instantiateViewControllerWithIdentifier(viewControllerIdentifier:String, storyboardName:String, bundle:NSBundle?) -> UIViewController{
    let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
    
    return storyboard.instantiateViewControllerWithIdentifier(viewControllerIdentifier)
  }
  public static func instantiateViewControllerWithIdentifier(viewControllerIdentifier:String, storyboardName:String) -> UIViewController{
    return instantiateViewControllerWithIdentifier(viewControllerIdentifier, storyboardName:storyboardName, bundle:nil)
  }
  
  public static func userDefaultsObjectForKey(key:String) -> AnyObject?{
    return GRUtils.standardUserDefaults.objectForKey(key)
  }
  
  public static func setUserDefaultsObject(object:AnyObject?, forKey key:String){
    GRUtils.standardUserDefaults.setObject(object, forKey: key)
    GRUtils.standardUserDefaults.synchronize()
  }
  
  public static func resetUserDefaults(){
    GRUtils.standardUserDefaults.setPersistentDomain([String:AnyObject](), forName:GRUtils.mainBundle.bundleIdentifier!);
    GRUtils.standardUserDefaults.synchronize()
    
  }
  

  
  public static func stringFromClass(aClass:AnyClass) -> String{
    let nameSpaceClassName = NSStringFromClass(aClass)
    return nameSpaceClassName.componentsSeparatedByString(".").last!
    
  }
  public static func instantiateViewForNibName(nibName:String) -> UIView?{
    return instantiateViewForNibName(nibName, bundle: GRUtils.mainBundle)
  }
  public static func instantiateViewForNibWithClass(aClass:AnyClass) -> UIView?{
    return instantiateViewForNibName(stringFromClass(aClass), bundle: GRUtils.mainBundle)
  }
  
  public static func instantiateViewForNibName(nibName:String, bundle:NSBundle) -> UIView?{
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let nibObjects:[AnyObject]? = nib.instantiateWithOwner(nil, options: nil)
    guard nibObjects?.count > 0 else { return nil }
    
    return (nibObjects?[0] as? UIView)
  }
  
  
}