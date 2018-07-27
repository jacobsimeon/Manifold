//
//  StreamStitcher.swift
//  Manifold
//
//  Created by pivotal on 7/26/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

class StreamStitcher {
  private let writer: StreamWriter
  private var reader: StreamReader?

  private var readCompletion: (() -> ())?
  private var canReadImmediately = false

  init(writer: StreamWriter) {
    self.writer = writer

    writer.delegate = self
  }

  func stitch(input: InputStream, completion: @escaping () -> ()) {
    DispatchQueue.main.async {
      self.reader = StreamReader(input: input)
      self.reader?.delegate = self
      self.readCompletion = completion
      self.reader?.openStream()

      if(self.canReadImmediately) {
        print("can read immediately")
        self.reader?.read()
      }
    }
  }

  func stitch(string: String, completion: @escaping () -> ()) {
    let stringInput = InputStream(data: string.data(using: .utf8)!)
    self.stitch(input: stringInput, completion: completion)
  }

  func done() {
    self.writer.done()
  }
}

extension StreamStitcher: StreamReaderDelegate {
  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data) {
    self.writer.write(chunk)
  }

  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader) {
    self.reader?.close()
    self.reader = nil

    self.readCompletion?()
    self.readCompletion = nil
  }
}

extension StreamStitcher: StreamWriterDelegate {
  func streamWriterHasSpaceAvailable(_: StreamWriter) {
    if let reader = reader {
      reader.read()
    }
    else {
      canReadImmediately = true
    }
  }
}
