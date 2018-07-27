//
//  Asset.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/21/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import Foundation

let baseURLString = "http://0.0.0.0:8080" as NSString
// let baseURLString = "http://10.0.1.19:8080" as NSString

struct Asset : Codable {
  let uri: String

  var url: URL! {
    let urlString = baseURLString.appendingPathComponent(uri)
    return URL(string: urlString)
  }
}
