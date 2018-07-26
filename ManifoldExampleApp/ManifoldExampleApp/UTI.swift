//
//  UTI.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/22/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import MobileCoreServices

struct UTI {
  let utiString: String

  init(string: String) {
    self.utiString = string
  }

  var mimeType: String {
    return value(for: kUTTagClassMIMEType) ?? ""
  }

  var fileExtension: String {
    return value(for: kUTTagClassFilenameExtension) ?? ""
  }

  private func value(for tagName: CFString) -> String? {
    let tagName = kUTTagClassFilenameExtension
    let value = UTTypeCopyPreferredTagWithClass(utiString as CFString, tagName)

    return value?.takeUnretainedValue() as String?
  }
}
