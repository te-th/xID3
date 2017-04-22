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

/// Verifies basic ID3Tag and Frame extraction.
class ID3TagTest: XCTestCase {

    /// Verifies that an empty InputStream results in an absent ID3Tag.
    func testEmptyInput() {
        let emptyStream = InputStream(data: Data(bytes: [UInt8]()))
        TestUtils.expectedAbsentID3Tag(emptyStream)
    }

    /// Verifies that an input not starting with "ID3" results in an absent ID3Tag.
    func testNonId3TaggedInput() {
        let nonId3Tag = "<invalid>".data(using: String.Encoding.utf16)
        TestUtils.expectedAbsentID3Tag(InputStream(data: nonId3Tag!))
    }

    /// Verifies that an input not starting with "ID3" results in an absent ID3Tag.
    func testWithVersion() {

        var data = TestUtils.ID3()
        data.append(TestUtils.id3v3.bytes())

        let id3Tag = TestUtils.id3Tag(from: InputStream(data: data))

        XCTAssertNotNil(id3Tag)
        XCTAssertEqual(id3Tag!.identifier.version, TestUtils.id3v3)
    }

    /// Verifies having one frame
    func testWithOneFrame() {
        let frameContent = "Hello".id3FrameContent(encoding: String.Encoding.utf8)

        var frameData = "TIT2".data(using: String.Encoding.utf8)!
        frameData.append(Data(bytes: frameContent.size))
        frameData.append(TestUtils.noFrameTags)
        frameData.append(frameContent.data)

        var id3Data = TestUtils.ID3()

        id3Data.append(TestUtils.id3v3.bytes())
        id3Data.append(TestUtils.noTags)
        id3Data.append(Data(bytes: [UInt8(0), UInt8(0), UInt8(0), UInt8(frameData.count + frameContent.data.count)]))
        id3Data.append(frameData)

        let id3Tag = TestUtils.id3Tag(from: InputStream(data: id3Data))

        XCTAssertNotNil(id3Tag)
        XCTAssertEqual(id3Tag!.rawFrames().count, 1)
        XCTAssertEqual(id3Tag!.rawFrames().first!.id, "TIT2")
        XCTAssertEqual(id3Tag!.rawFrames().first!.content, frameContent.bytes)
    }

    /// Verifies having two frames
    func testWithTwoFrames() {
        let contentFrameOne = "Hello".id3FrameContent(encoding: String.Encoding.utf8)

        var dataFrameOne = "TIT2".data(using: String.Encoding.utf8)!
        dataFrameOne.append(Data(bytes: contentFrameOne.size))
        dataFrameOne.append(TestUtils.noFrameTags)
        dataFrameOne.append(contentFrameOne.data)

        let contentFrameTwo = "World".id3FrameContent(encoding: String.Encoding.utf8)
        var dataFrameTwo = "XXXX".data(using: String.Encoding.utf8)!
        dataFrameTwo.append(Data(bytes: contentFrameTwo.size))
        dataFrameTwo.append(TestUtils.noFrameTags)
        dataFrameTwo.append(contentFrameTwo.data)

        var id3Data = TestUtils.ID3()

        id3Data.append(TestUtils.id3v3.bytes())
        id3Data.append(TestUtils.noTags)
        id3Data.append(Data(bytes: [UInt8(0), UInt8(0), UInt8(0), UInt8(dataFrameOne.count + contentFrameOne.data.count + dataFrameTwo.count + contentFrameTwo.data.count)]))
        id3Data.append(dataFrameOne)
        id3Data.append(dataFrameTwo)

        let id3Tag = TestUtils.id3Tag(from: InputStream(data: id3Data))

        XCTAssertNotNil(id3Tag)
        XCTAssertEqual(id3Tag!.rawFrames().count, 2)
        XCTAssertEqual(id3Tag!.rawFrames()[0].id, "TIT2")
        XCTAssertEqual(id3Tag!.rawFrames()[0].content, contentFrameOne.bytes)

        XCTAssertEqual(id3Tag!.rawFrames()[1].id, "XXXX")
        XCTAssertEqual(id3Tag!.rawFrames()[1].content, contentFrameTwo.bytes)
    }
}
