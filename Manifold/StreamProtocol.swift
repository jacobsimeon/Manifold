import Foundation

public protocol StreamProtocol: class {
  var delegate: StreamDelegate? { get set }

  var streamError: Error? { get }

  func close()

  func open()

  func schedule(in aRunLoop: RunLoop, forMode mode: RunLoopMode)

  func remove(from aRunLoop: RunLoop, forMode mode: RunLoopMode)
}

public protocol InputStreamProtocol: StreamProtocol {
  func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int
}

public protocol OutputStreamProtocol: StreamProtocol {
  func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int
}

extension InputStream: InputStreamProtocol {
}

extension OutputStream: OutputStreamProtocol {
}


