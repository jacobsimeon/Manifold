//
//  FakeStreamReaderFactory.swift
//  ManifoldTests
//
//  Created by Pivotal on 8/9/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

@testable import Manifold

class FakeStreamReaderFactory : StreamReaderFactory {
  var streamReaderImpl: ((InputStreamProtocol) -> StreamReader)?

  func onStreamReader(impl: @escaping (InputStreamProtocol) -> StreamReader) {
    streamReaderImpl = impl
  }

  func streamReader(input: InputStreamProtocol) -> StreamReader {
    guard let impl = streamReaderImpl else {
      fatalError("\(FakeStreamReaderFactory.self).streamReader is not stubbed")
    }

    return impl(input)
  }
}
