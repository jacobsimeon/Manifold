//
//  TestManifoldDelegate.swift
//  ManifoldTests
//
//  Created by Jacob Morris on 7/30/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
import Manifold

class TestManifoldDelegate : ManifoldDelegate {
  var finishImpl: ((Manifold, InputStream) -> ())?
  var failureImpl: ((Manifold, Error) -> ())?

  func onManifoldDidFailWithError(impl: @escaping (Manifold, Error) -> ()) {
    failureImpl = impl
  }

  func onManifoldDidFinishEncoding(
    impl: @escaping (Manifold, InputStream) -> ()
  ) {
    finishImpl = impl
  }

  func manifold(_ manifold: Manifold, didFailWithError error: Error) {
    failureImpl?(manifold, error)
  }

  func manifold(_ manifold: Manifold, didFinishEncoding stream: InputStream) {
    finishImpl?(manifold, stream)
  }
}
