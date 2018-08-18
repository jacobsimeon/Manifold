//
//  StreamStitcher.swift
//  Manifold
//
//  Created by pivotal on 7/26/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol StreamStitcherDelegate: class {
  func streamStitcherDidFinishStitchingStream(_ stitcher: StreamStitcher)
  func streamStitcherDidCloseStream(_ stitcher: StreamStitcher)
  func streamStitcher(_ stitcher: StreamStitcher, didFailWithError error: Error)
}

public protocol StreamStitcher: class {
  var delegate: StreamStitcherDelegate? { get set }

  func stitch(input: InputStreamProtocol)
  func done()
}

class IOStreamStitcher: StreamStitcher {
  private let writer: StreamWriter
  private let readerFactory: StreamReaderFactory
  private var reader: StreamReader?

  public weak var delegate: StreamStitcherDelegate?

  init(writer: StreamWriter, readerFactory: StreamReaderFactory) {
    self.readerFactory = readerFactory

    self.writer = writer
    writer.delegate = self
    writer.open()
  }

  func stitch(input: InputStreamProtocol) {
    reader = nil

    reader = readerFactory.streamReader(input: input)
    reader?.delegate = self
    reader?.open()
  }

  func done() {
    writer.done()
  }
}

extension IOStreamStitcher: StreamReaderDelegate {
  func streamReader(
    _ streamReader: StreamReader,
    didFailWithError error: Error
  ) {
    delegate?.streamStitcher(self, didFailWithError: error)
  }

  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data) {
    writer.write(chunk)
  }

  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader) {
    reader?.close()
    reader = nil

    delegate?.streamStitcherDidFinishStitchingStream(self)
  }
}

extension IOStreamStitcher: StreamWriterDelegate {
  func streamWriter(
    _ streamWriter: StreamWriter,
    didFailWithError error: Error
  ) {
    delegate?.streamStitcher(self, didFailWithError: error)
  }

  func streamWriterDidCloseStream(_ streamWriter: StreamWriter) {
    delegate?.streamStitcherDidCloseStream(self)
  }
}
