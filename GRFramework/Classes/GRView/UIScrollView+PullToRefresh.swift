//
//  UIScrollView+PullToRefresh.swift
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
/*
@objc protocol GRPullToRefreshDelegate:UIScrollViewDelegate {
  func pullToRefreshTriggeredWithRatio(ratio:CGFloat)
  func pullToRefreshDidStartLoading()
  func pullToRefreshDidStoppedLoading()
}*/

var GRPullToRefreshView:UInt = 0

extension UIScrollView{
  public var pullToRefreshView:GRRefreshView?{
    get {
      return objc_getAssociatedObject(self, &GRPullToRefreshView) as? GRRefreshView
    }
    
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &GRPullToRefreshView, newValue as GRRefreshView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC )
      }
    }
    
  }

  
  public func addPullToRefreshWithActionHandler(actionHandler:GRRefreshView.GRRefreshViewActionHandler, refreshView:GRRefreshView){
    if let pullToRefreshView = pullToRefreshView {
      pullToRefreshView.removeFromSuperview()
      self.infiniteScrollingView = nil
    }
    refreshView.frame = CGRectMake((CGRectGetWidth(frame)-CGRectGetWidth(refreshView.frame))/2,
      -CGRectGetHeight(refreshView.frame),
      CGRectGetWidth(refreshView.frame),
      CGRectGetHeight(refreshView.frame));
    refreshView.pullToRefreshActionHandler = actionHandler
    refreshView.scrollView = self
    addSubview(refreshView)
    refreshView.originalBottomInset = contentInset.top;
    refreshView.refreshStyle = .PullToRefresh;
    
    pullToRefreshView = refreshView;
    showsPullToRefresh = true
  }
  
  public func triggerPullToRefresh (){
    pullToRefreshView?.pullToRefreshState = .Triggered;
    pullToRefreshView?.pullToRefreshState = .Loading;

  }
  
  public var showsPullToRefresh: Bool {
    get{
      
      return !(pullToRefreshView?.hidden ?? false)
    }
    set{
      guard let pullToRefreshView = pullToRefreshView else { return }
      if !newValue && pullToRefreshView.isObserving {
        removeObserver(pullToRefreshView, forKeyPath: "contentOffset")
        removeObserver(pullToRefreshView, forKeyPath: "frame")
        pullToRefreshView.resetScrollViewContentInset()
        pullToRefreshView.isObserving = false
      }
      else if newValue && !pullToRefreshView.isObserving {
        addObserver(pullToRefreshView, forKeyPath: "contentOffset", options: .New, context: nil)
        addObserver(pullToRefreshView, forKeyPath: "frame", options: .New, context: nil)
        pullToRefreshView.isObserving = true
      }
    }
  }
}
