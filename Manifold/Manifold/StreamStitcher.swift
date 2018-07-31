//
//  StreamStitcher.swift
//  Manifold
//
//  Created by pivotal on 7/26/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

protocol StreamStitcherDelegate: class {
  func streamStitcherDidFinishStitchingStream(_ stitcher: StreamStitcher)
  func streamStitcherDidCloseStream(_ stitcher: StreamStitcher)
}

class StreamStitcher {
  private let writer: StreamWriter
  private var reader: StreamReader?

  public weak var delegate: StreamStitcherDelegate?

  init(writer: StreamWriter) {
    self.writer = writer
    writer.delegate = self
  }

  func stitch(input: InputStream) {
    self.reader = nil

    self.reader = StreamReader(input: input)
    self.reader?.delegate = self
    self.reader?.open()
  }

  func done() {
    writer.done()
  }
}

extension StreamStitcher: StreamReaderDelegate {
  func streamReaderDidReadChunk(_ chunk: Data) {
    self.writer.write(chunk)
  }

  func streamReaderDidReachEndOfStream() {
    self.reader?.close()
    self.delegate?.streamStitcherDidFinishStitchingStream(self)
  }
}

extension StreamStitcher: StreamWriterDelegate {
  func streamWriterDidCloseStream(_ streamWriter: StreamWriter) {
    self.delegate?.streamStitcherDidCloseStream(self)
  }
}
