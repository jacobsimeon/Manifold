//
//  Part.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class Part {
  private var body: InputStream?
  private var headers: [String: String]

  public init() {
    headers = [:]
  }
  
  public func header(_ name: String, _ value: String) {
    headers[name] = value
  }
  
  public func body(_ body: InputStream) {
    self.body = body
  }

  func write(with stitcher: StreamStitcher, completion: @escaping () -> ()) {
    var headersString = headers.map({ (key, value) -> String in
      "\(key): \(value)"
    }).joined(separator: Manifold.lineEnding)
    headersString += Manifold.lineEnding
    headersString += Manifold.lineEnding

    stitcher.stitch(string: headersString) {
      stitcher.stitch(input: self.body!, completion: completion)
    }
  }
}
