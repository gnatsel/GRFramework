//
//  UIViewController+GRViewController.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 1/09/2015.
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

import UIKit

public typealias CompletionHandler = () -> ()

extension UIViewController {
  public static var defaultStoryboardIdentifier : String{
    get{
      return GRUtils.stringFromClass(self) + "Identifier"
    }
  }
  public static var defaultStoryboardUnwindIdentifier : String{
    get{
      return GRUtils.stringFromClass(self) + "UnwindIdentifier"
    }
  }
  public var backViewController : UIViewController? {
    var stack = self.navigationController!.viewControllers
    for i in (1...stack.count-1).reverse() {
      if (stack[i] as UIViewController == self) {
        return stack[i-1]
      }
      
    }
    return nil
  }
  
  
  public func showSettingsAlert(title: String, message: String) {
    let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
      if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
    
    showAlertWithTitle(title, message: message, actions: [openAction])
  }

  public func showAlertWithTitle(title:String?, message:String?) {
    showAlertWithTitle(title, message:message, actions:[UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler:nil)], usesDefaultCancelAction:false)
  }
  
  public func showAlertWithTitle(title:String?, message:String?, actionText:String = "OK", completion: (()->())?) {
    showAlertWithTitle(title, message:message, actions:[UIAlertAction(title: actionText, style: UIAlertActionStyle.Cancel){
      _ in
      completion?()
      }], usesDefaultCancelAction:false)
  }
  
  public func showAlertWithTitle(title:String?, message:String?, actions:[UIAlertAction]?) {
    showAlertWithTitle(title, message:message, actions:actions, usesDefaultCancelAction:true)
  }
  
  public func showAlertWithTitle(title:String?, message:String?, actions:[UIAlertAction]?, usesDefaultCancelAction:Bool) {
    showAlertControllerWithTitle(title, message:message, style:UIAlertControllerStyle.Alert, actions:actions, usesDefaultCancelAction:usesDefaultCancelAction)
  }
  
  public func showActionSheetWithActions(actions:[UIAlertAction]?){
    showActionSheetWithTitle(nil, message:nil, actions:actions, usesDefaultCancelAction:true)
  }
  
  public func showActionSheetWithActions(actions:[UIAlertAction]?, usesDefaultCancelAction:Bool){
    showActionSheetWithTitle(nil, message:nil, actions:actions, usesDefaultCancelAction:usesDefaultCancelAction)
  }
  
  public func showActionSheetWithTitle(title:String?, message:String?, actions:[UIAlertAction]?) {
    showActionSheetWithTitle(title, message:message, actions:actions, usesDefaultCancelAction:true)
  }
  
  public func showActionSheetWithTitle(title:String? = nil, message:String? = nil, actions:[UIAlertAction]? = nil, usesDefaultCancelAction:Bool = true){
    showAlertControllerWithTitle(title, message:message, style:.ActionSheet, actions:actions, usesDefaultCancelAction:usesDefaultCancelAction)
  }
  
  public func showAlertControllerWithTitle(title:String? = nil, message:String? = nil, style:UIAlertControllerStyle? = nil, actions:[UIAlertAction]? = nil, usesDefaultCancelAction:Bool = true) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: style ?? UIAlertControllerStyle.Alert)
    if let actions = actions {
      for action in actions {
        alertController.addAction(action)
      }
    }
    if usesDefaultCancelAction {
      alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
    }
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  
  //MARK: Methods for unimplemented logic
  
  public func showUnimplementedKeywordAlert(keyword:String){
    showAlertWithTitle("Implementation missing", message: "This "+keyword+" has not been implemented yet")
  }
  
  public func showUnimplementedMethodAlert() {
    showUnimplementedKeywordAlert("method")
  }
  
  public func showUnimplementedActionAlert() {
    showUnimplementedKeywordAlert("action")
  }
  
  public func openSettings(){
    UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
  }
  
  public func showAlertForPermissionsDisabled(permission:String){
    showAlertWithTitle("\(permission) access denied", message:"To re-enable, please go to Settings and turn on \(permission) for this app.", actions:[
      UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
        self.openSettings()
      })])
  }
  
  public func isModal() -> Bool {
    if((self.presentingViewController) != nil) {
      return true
    }
    
    if(self.presentingViewController?.presentedViewController == self) {
      return true
    }
    
    if(self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
      return true
    }
    
    if((self.tabBarController?.presentingViewController?.isKindOfClass(UITabBarController)) != nil) {
      return true
    }
    
    return false
  }
  
  @IBAction public func closeModalAction(sender:AnyObject){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  public func performBlock(block:CompletionHandler, afterDelay delay:NSTimeInterval){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
  }
}
