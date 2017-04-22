/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

import XCTest
@testable import xID3

class TestUtils: XCTestCase {

    public static let id3v3 = ID3Version(UInt8(3), UInt8(0))
    public static let noTags = Data(bytes: [UInt8(0)])
    public static let noFrameTags = Data(bytes: [UInt8(0), UInt8(0)])

    public static func ID3() -> Data {
        return "ID3".data(using: String.Encoding.utf8)!
    }

    public static func expectedAbsentID3Tag(_ stream: InputStream) {
        let id3Tag = TestUtils.id3Tag(from: stream)
        XCTAssertNil(id3Tag)
    }

    public static func id3Tag(from: InputStream) -> ID3Tag? {
        from.open()
        let id3tag = ID3Reader.read(from)
        from.close()

        return id3tag
    }
}

extension ID3Version {
    func bytes() -> Data {
        return Data(bytes: [self.major, self.minor])
    }
}

typealias ID3FrameContent = (data: Data, bytes: [UInt8], size: [UInt8])

extension String {
    func id3FrameContent(encoding: String.Encoding) -> ID3FrameContent {
        var data = self.data(using: encoding)!
        let encodingFlag: Data
        switch encoding {
            case String.Encoding.utf8:
                encodingFlag = Data(bytes: [ID3Utils.utf8CharsetIndicator])
            case String.Encoding.isoLatin1:
                encodingFlag = Data(bytes: [ID3Utils.latin1CharsetIndicator])
            default:
                encodingFlag = Data(bytes: [UInt8(1)])
        }
        data.append(encodingFlag)

        var dataBytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &dataBytes, count: data.count)

        return (data, dataBytes, [UInt8(0), UInt8(0), UInt8(0), UInt8(dataBytes.count)])
    }
}

extension ID3Version : Equatable {

}

public func ==(this: ID3Version, that: ID3Version) -> Bool {
    return this.major == that.major && this.minor == that.minor
}
