//
//  HighlightTextView.swift
//  HighlightTextView
//
//  Created by KazukiYusa on 2016/10/10.
//  Copyright © 2016年 KazukiYusa. All rights reserved.
//

import UIKit

extension UITextView {
  
  private var condition: Condition? {
    get {
      
      let value = objc_getAssociatedObject(self, &StoredProperties.condition) as? Condition
      return value
    }
    set {
      
      objc_setAssociatedObject(
        self,
        &StoredProperties.condition,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }
  
  private var maxLocationLength: Int? {
    get {
      
      let value = objc_getAssociatedObject(self, &StoredProperties.maxLocationLength) as? Int
      return value
    }
    set {
      
      objc_setAssociatedObject(
        self,
        &StoredProperties.maxLocationLength,
        newValue,
        objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }
  
  private struct StoredProperties {
    
    static var condition: Void?
    static var maxLocationLength: Void?
  }
  
  public func setHighlight(condition: Condition) {
    
    let min = condition.range.lowerBound
    
    if min != Int.min, text.characters.count < min {
      
      let attributes = NSMutableAttributedString(attributedString: attributedText)
      attributes.addAttributes([NSBackgroundColorAttributeName: condition.minHighlightColor],
                               range: NSRange(location: 0,
                                              length: text.characters.count))
      attributedText = attributes
    }
    
    NotificationCenter.default
      .addObserver(forName: .UITextViewTextDidChange,
                   object: nil,
                   queue: nil) { [weak self] _ in
                    self?.didChangeTextView()
    }
    
    self.condition = condition
  }
  
  private func didChangeTextView() {
    
    guard let condition = condition else {
      return
    }
    
    if markedTextRange != nil {
      return
    }
    
    let min = condition.range.lowerBound
    let max = condition.range.upperBound
    
    if min != Int.min {
      
      let color = text.characters.count >= min ? UIColor.clear : condition.minHighlightColor
      
      let attributes = NSMutableAttributedString(attributedString: attributedText)
      attributes.addAttributes([NSBackgroundColorAttributeName: color],
                               range: NSRange(location: 0,
                                              length: attributedText.length))
      attributedText = attributes
    }
    
    if max != Int.max, text.characters.count >= max {
      
      let attributes = NSMutableAttributedString(attributedString: attributedText)
      attributes.addAttributes([NSBackgroundColorAttributeName: condition.maxHighlightColor],
                               range: NSRange(location: max,
                                              length: attributedText.length - max))
      attributedText = attributes
    }
  }
}
