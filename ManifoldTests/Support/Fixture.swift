//
//  Fixture.swift
//  ManifoldTests
//
//  Created by Jacob Morris on 7/30/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

class Fixture {
  private static let bundle = Bundle(for: Fixture.self)
  private let name: String
  private let ext: String

  init(name: String) {
    let parts = name.split(separator: ".")

    self.name = String(parts[0])
    self.ext = String(parts[1])
  }

  var resourceName: String {
    return "Fixtures/\(name)"
  }

  var url: URL {
    guard let url = Fixture.bundle.url(
      forResource: resourceName,
      withExtension: ext
    ) else {
      fatalError("Unable to locate fixture named \(name) with extension \(ext)")
    }

    return url
  }

  var input: InputStream {
    guard let stream = InputStream(url: url) else {
      fatalError("Unable to locate fixture named \(name) with extension \(ext)")
    }

    return stream
  }

  var data: Data {
    guard let data = try? Data(contentsOf: url) else {
      fatalError("Unable to locate fixture named \(name) with extension \(ext)")
    }

    return data
  }
}
