//
//  EncodingError.swift
//  Manifold
//
//  Created by pivotal on 8/2/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public enum ManifoldError : Error {
  case generic(String)
  case streamWriteError(Error?)
  case streamReadError(Error?)
}
