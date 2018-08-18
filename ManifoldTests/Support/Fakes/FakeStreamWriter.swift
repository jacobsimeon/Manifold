//
//  FakeStreamWriter.swift
//  ManifoldTests
//
//  Created by Pivotal on 8/9/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

@testable import Manifold

class FakeStreamWriter : StreamWriter {
  var delegate: StreamWriterDelegate?
  
  func write(_ data: Data) {
    
  }

  func open() {
    
  }
  
  func done() {
    
  }
}
