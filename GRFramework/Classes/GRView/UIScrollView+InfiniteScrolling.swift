//
//  UIScrollView+InfiniteScrolling.swift
//
//  Created by Gnatsel Reivilo on 06/01/2015.
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

var GRInfiniteScrollingView:UInt = 0

extension UIScrollView {
  public var infiniteScrollingView : GRRefreshView? {
    get {
      return objc_getAssociatedObject(self, &GRInfiniteScrollingView) as? GRRefreshView
    }
    
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &GRInfiniteScrollingView, newValue as GRRefreshView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC )
      }
    }
    
    
  }
  

  
  public func addInfiniteScrollingWithActionHandler(actionHandler:GRRefreshView.GRRefreshViewActionHandler, refreshView:GRRefreshView){
    if let infiniteScrollingView = infiniteScrollingView {
      infiniteScrollingView.removeFromSuperview()
      self.infiniteScrollingView = nil
    }
    refreshView.frame = CGRect(x: (bounds.size.width - refreshView.frame.size.width)/2, y: bounds.size.height, width: refreshView.frame.size.width, height: refreshView.frame.size.height)
    refreshView.infiniteScrollingActionHandler = actionHandler
    refreshView.scrollView = self
    addSubview(refreshView)
    refreshView.originalBottomInset = contentInset.bottom;
    refreshView.refreshStyle = .InfiniteScrolling;
    
    self.infiniteScrollingView = refreshView;
    showsInfiniteScrolling = true
  }
  
  public func triggerInfiniteScrolling (){
    infiniteScrollingView?.infiniteScrollingState = .Triggered
  infiniteScrollingView?.infiniteScrollingState = .Loading
  }
 
  public var showsInfiniteScrolling: Bool {
    get{
     
      return !(infiniteScrollingView?.hidden ?? false)
    }
    set{
      guard let infiniteScrollingView = infiniteScrollingView else { return }
      if !newValue && infiniteScrollingView.isObserving {
        removeObserver(infiniteScrollingView, forKeyPath: "contentOffset")
        removeObserver(infiniteScrollingView, forKeyPath: "contentSize")
        infiniteScrollingView.resetScrollViewContentInset()
        infiniteScrollingView.isObserving = false
      }
      else if newValue && !infiniteScrollingView.isObserving {
        addObserver(infiniteScrollingView, forKeyPath: "contentOffset", options: .New, context: nil)
        addObserver(infiniteScrollingView, forKeyPath: "contentSize", options: .New, context: nil)
        infiniteScrollingView.setScrollViewContentInsetForInfiniteScrolling()
        infiniteScrollingView.isObserving = true
        infiniteScrollingView.setNeedsLayout()
        infiniteScrollingView.frame = CGRect(x: (bounds.size.width - infiniteScrollingView.frame.size.width)/2, y: contentSize.height, width: infiniteScrollingView.frame.size.width, height: infiniteScrollingView.frame.size.height)
      }
    }
  }

}
