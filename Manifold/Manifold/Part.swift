//
//  Part.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class Part {
  var body: InputStream?
  var headers: [String: String]

  public init() {
    headers = [:]
  }
  
  public func header(_ name: String, _ value: String) {
    headers[name] = value
  }
  
  public func body(_ body: InputStream) {
    self.body = body
  }
}
