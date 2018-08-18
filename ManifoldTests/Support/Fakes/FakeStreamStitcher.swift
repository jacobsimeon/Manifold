//
//  FakeStreamStitcher.swift
//  ManifoldTests
//
//  Created by Pivotal on 8/9/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//


@testable import Manifold

class FakeStreamStitcher : StreamStitcher {
  var delegate: StreamStitcherDelegate?
  
  func stitch(input: InputStreamProtocol) {
    
  }
  
  func done() {
    
  }
}
