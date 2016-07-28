//
//  GRLabel.swift
//  GRFramework
//
//  Created by Gnatsel Reivilo on 4/09/2015.
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

public class GRLabel: UILabel {
  
  @IBInspectable public var hasBottomBorder:Bool = false {
    didSet {
      setupView()
    }
  }
  
  @IBInspectable public var bottomBorderColor:UIColor = UIColor.clearColor() {
    didSet {
      setupView()
    }
  }
  
  @IBInspectable public var isRounded : Bool = false {
    didSet{
      setupView()
    }
    
  }
  
  @IBInspectable public var letterSpacing : CGFloat = 0 {
    didSet{
      setupView()
    }
    
  }
  
  var bottomLayer:CALayer = CALayer()
  
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    // Initialization code
    setupView()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  
  
  
  public func setupView(){
    if hasBottomBorder {
      bottomLayer.backgroundColor = bottomBorderColor.CGColor
      bottomLayer.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0);
      if bottomLayer.superlayer == nil {
        self.layer.addSublayer(bottomLayer)
      }
      
    }
    else {
      if bottomLayer.superlayer != nil {
        bottomLayer.removeFromSuperlayer()
      }
    }
    if(isRounded) {
      layer.cornerRadius = frame.size.width / 2
    }
    else {
      layer.cornerRadius = 0
    }
    
    if letterSpacing > 0 {
      guard let text = text else { return }
      self.attributedText = NSAttributedString(string: text, attributes: [NSKernAttributeName : letterSpacing])
    }
  
  }
  
  override public func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setupView()
  }
  
  
}
