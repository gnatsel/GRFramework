//
//  UIView+GRPresenter.swift
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

import UIKit
import Foundation
import QuartzCore
import ObjectiveC

var UIGRPresenter:UInt = 0

extension UIView {
    @IBOutlet public var presenter : GRPresenter? {
        get {
            return objc_getAssociatedObject(self, &UIGRPresenter) as? GRPresenter
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &UIGRPresenter, newValue as GRPresenter?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC )
            }
        }
    }
}
