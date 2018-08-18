//
//  TestStreamStitcherDelegate.swift
//  ManifoldTests
//
//  Created by pivotal on 8/14/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

@testable
import Manifold

class TestStreamStitcherDelegate : StreamStitcherDelegate {
  var streamStitcherDidFailWithErrorImpl: ((StreamStitcher, Error) -> ())?

  func onStreamStitcherDidFailWithError(
    impl: @escaping (StreamStitcher, Error) -> ()
  ) {
    streamStitcherDidFailWithErrorImpl = impl
  }

  func streamStitcher(
    _ stitcher: StreamStitcher,
    didFailWithError error: Error
    ) {
    streamStitcherDidFailWithErrorImpl?(stitcher, error)
  }

  func streamStitcherDidFinishStitchingStream(_ stitcher: StreamStitcher) {
    let msg = """
    \(TestStreamStitcherDelegate.self) does not implement the following method:
    `\(#function)`
    """

    fatalError(msg)
  }

  func streamStitcherDidCloseStream(_ stitcher: StreamStitcher) {
    let msg = """
    \(TestStreamStitcherDelegate.self) does not implement the following method:
    `\(#function)`
    """

    fatalError(msg)
  }
}
