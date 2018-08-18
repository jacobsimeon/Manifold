//
//  StreamReaderFactory.swift
//  Manifold
//
//  Created by Pivotal on 8/9/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

protocol StreamReaderFactory {
    func streamReader(input: InputStreamProtocol) -> StreamReader
}

class InputStreamReaderFactory : StreamReaderFactory {
    func streamReader(input: InputStreamProtocol) -> StreamReader {
        return InputStreamReader(input: input)
    }
}
