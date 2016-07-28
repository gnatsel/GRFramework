//
//  GRCustomRefreshView
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

public enum GRPullToRefreshState:Int{
  case Stopped
  case Triggered
  case Loading
}

public enum GRInfiniteScrollingState:Int{
  case Stopped
  case Triggered
  case Loading
}

public enum GRRefreshStyle:Int {
  case None
  case PullToRefresh
  case InfiniteScrolling
};

public  class GRRefreshView: UIView {
  
  public var scrollView:UIScrollView?
  public var originalTopInset:CGFloat = 0
  public var originalBottomInset:CGFloat = 0

  
  public var isObserving = false
  public var wasTriggeredByUser = false

  public var refreshStyle = GRRefreshStyle.None
  
  public typealias GRRefreshViewActionHandler = () -> ()
  public var pullToRefreshActionHandler:GRRefreshViewActionHandler?
  public var infiniteScrollingActionHandler:GRRefreshViewActionHandler?

  public var pullToRefreshState:GRPullToRefreshState = GRPullToRefreshState.Stopped {
    willSet{
      guard pullToRefreshState != newValue else { return }
      switch newValue {
      case .Stopped:
        resetScrollViewContentInset()
        break
      case .Triggered: break
      case .Loading:
        startRefreshing()
        setScrollViewContentInsetForLoading()
        guard pullToRefreshState == .Triggered else { break }
        pullToRefreshActionHandler?()
      }
    }
  }
  public var infiniteScrollingState:GRInfiniteScrollingState = GRInfiniteScrollingState.Stopped {
    willSet{
      guard infiniteScrollingState != newValue else { return }
      switch newValue {
      case .Stopped: break
      case .Triggered: break
      case .Loading:
        startRefreshing()
        guard infiniteScrollingState == .Triggered else { break }
        infiniteScrollingActionHandler?()
      }
    }
  }
  
  override public func willMoveToSuperview(newSuperview: UIView?) {
    guard let scrollView = superview as? UIScrollView else { return }
    guard isObserving else { return }
    if refreshStyle == .PullToRefresh && scrollView.showsPullToRefresh {
      
      scrollView.removeObserver(self, forKeyPath: "contentOffset", context:nil)
      scrollView.removeObserver(self, forKeyPath: "frame", context: nil)
      isObserving = false
    } else if refreshStyle == .InfiniteScrolling && scrollView.showsInfiniteScrolling {
      scrollView.removeObserver(self, forKeyPath: "contentOffset", context: nil)
      scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
      isObserving = false
    }
  }
  
  public func resetScrollViewContentInset() {
    guard let scrollView = scrollView else { return }
    var currentInsets = scrollView.contentInset
    currentInsets.top = originalTopInset
    setScrollViewContentInset(currentInsets)
  }
  
  public func setScrollViewContentInsetForLoading() {
    guard let scrollView = scrollView else { return }
    var currentInsets = scrollView.contentInset
    currentInsets.top = originalTopInset
    setScrollViewContentInset(currentInsets)
  }

  public func setScrollViewContentInset(contentInset:UIEdgeInsets) {
    UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: { [weak self] () -> Void in
      self?.scrollView?.contentInset = contentInset
      }, completion: nil )
  }

  
  public func pullToRefreshTriggeringWithRatio(ratio:CGFloat){
  
  }
  public func infiniteScrollingTriggeringWithRatio(ratio:CGFloat){
    
  }
  
  
  public func setScrollViewContentInsetForInfiniteScrolling() {
    guard let scrollView = scrollView else { return }
    var currentInsets = scrollView.contentInset;
    currentInsets.bottom = originalBottomInset + self.frame.size.height;
    setScrollViewContentInset(currentInsets)
  }
  public func startRefreshing(){
    guard let scrollView = scrollView else { return }
    if(fabs(scrollView.contentOffset.y ?? 0) < CGFloat(FLT_EPSILON)) {
      scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, -self.frame.size.height), animated:true);
      self.wasTriggeredByUser = false;
    }
    else{
      self.wasTriggeredByUser = true;
    }
  }
  public func endRefreshing(){
    if(self.refreshStyle == .PullToRefresh){
      self.pullToRefreshState = .Stopped;
      guard let scrollView = scrollView else { return }
      if(!wasTriggeredByUser && scrollView.contentOffset.y < -originalTopInset){
        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, -originalTopInset), animated:true)
      }
    }
    if(self.refreshStyle == .InfiniteScrolling){
      self.infiniteScrollingState = .Stopped;
    }
  }
  
  

  
  public func scrollViewDidScrollForPullToRefresh(contentOffset:CGPoint) {
    guard let scrollView = scrollView else { return }
    var ratio = -(self.originalTopInset+scrollView.contentOffset.y + CGRectGetHeight(frame)/2)/CGRectGetHeight(frame)
    ratio = ratio < 0 ? 0 : ratio
    ratio = ratio > 1 ? 1 : ratio
    if pullToRefreshState != .Loading {
      
      if pullToRefreshState == .Triggered && ratio == 1 {
        self.pullToRefreshState = .Loading;
        pullToRefreshTriggeringWithRatio(ratio)
      }
      else if ratio < 1 && scrollView.dragging && pullToRefreshState != .Loading {
        pullToRefreshState = .Triggered;
        pullToRefreshTriggeringWithRatio(ratio)
      }
      else if !scrollView.dragging && self.pullToRefreshState != .Stopped {
        pullToRefreshTriggeringWithRatio(0)
      }
    } else {
      var offset = max(scrollView.contentOffset.y * -1, 0.0)
      offset = min(offset, originalTopInset + bounds.size.height)
      let contentInset = scrollView.contentInset
      scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right)
    }
  }

  
  public func scrollViewDidScrollForInfiniteScrolling(contentOffset:CGPoint){
    guard let scrollView = scrollView else { return }
    if infiniteScrollingState != .Loading {
      var ratio:CGFloat = 0;
      if scrollView.contentOffset.y >= 0  {
        ratio = (scrollView.contentOffset.y+scrollView.frame.size.height-scrollView.contentSize.height)/(2*frame.size.height)
        ratio = ratio < 0 ? 0 : ratio;
        ratio = ratio > 1 ? 1 : ratio;
      }
      
      if self.infiniteScrollingState == .Triggered && ratio == 1 {
        infiniteScrollingState = .Loading;
      }
      else if ratio <= 1 && scrollView.dragging && infiniteScrollingState == .Stopped {
        infiniteScrollingState = .Triggered
      }
      else if(!scrollView.dragging && infiniteScrollingState != .Stopped) {
        infiniteScrollingState = .Stopped
      }
    }
  }
  
  public func scrollViewDidScroll(contentOffset:CGPoint) {
    switch(refreshStyle){
    case .None: break
    case .PullToRefresh:
      scrollViewDidScrollForPullToRefresh(contentOffset)
      break
    case .InfiniteScrolling:
      scrollViewDidScrollForInfiniteScrolling(contentOffset)
      break
    }
  }
  
  
  override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentOffset" {
      guard let value = change?[NSKeyValueChangeNewKey] as? NSValue else {
        return
      }
      scrollViewDidScroll(value.CGPointValue())
    }
    else if keyPath == "frame" {
      layoutSubviews()
    }
    else if keyPath == "contentInset" {
      guard let value = change?[NSKeyValueChangeNewKey] as? NSValue else {
        return
      }
      let inset = value.UIEdgeInsetsValue()
      originalTopInset = inset.top
      originalBottomInset = inset.bottom
    }
    else if keyPath == "contentSize" && refreshStyle == .InfiniteScrolling{
      layoutSubviews()
      guard let scrollView = scrollView else { return }
      frame = CGRectMake(frame.origin.x, scrollView.contentSize.height, bounds.size.width, bounds.size.height);
    }
  }
}



