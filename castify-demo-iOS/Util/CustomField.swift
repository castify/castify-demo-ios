// Copyright © 2019 evaluni.com. All rights reserved.

import Foundation

class CustomField<T> {
  
  subscript(obj: AnyObject) -> T? {
    get {
      return objc_getAssociatedObject(obj, key(of: self)) as? T
    }
    set {
      objc_setAssociatedObject(obj, key(of: self), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

fileprivate func key(of obj: AnyObject) -> UnsafeMutableRawPointer {
  return Unmanaged.passUnretained(obj).toOpaque()
}
