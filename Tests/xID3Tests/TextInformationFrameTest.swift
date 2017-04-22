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
class TextInformationFrameTest: XCTestCase {

    /// Verifies successful Frame extracton
    func testFrameExtraction() {
        var byteBuffer = [ID3Utils.utf8CharsetIndicator]

        "Hello".utf8.forEach({byteBuffer.append($0)})
        let tagFrame = ID3TagFrame(id: "TIT2", size: 5, content: byteBuffer, flags: [UInt8(0)])
        let id3Frame = TextInformationFrameProcessor().from(tagFrame) as? TextInformationFrame

        XCTAssertNotNil(id3Frame)
        XCTAssertEqual(id3Frame!.frameId, "TIT2")
        XCTAssertEqual(id3Frame!.text, "Hello")
    }

    /// Verifies no Frame was extracted if only one byte of content is given
    func testTooFewData() {
        let tagFrame = ID3TagFrame(id: "TIT2", size: 5, content: [ID3Utils.utf8CharsetIndicator], flags: [UInt8(0)])
        let id3Frame = TextInformationFrameProcessor().from(tagFrame) as? TextInformationFrame

        XCTAssertNil(id3Frame)
    }
}
