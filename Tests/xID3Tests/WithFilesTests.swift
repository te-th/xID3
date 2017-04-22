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

/// Verifies loading MP3 Files and extracting ID3 Tag
class WithFilesTest: XCTestCase {

    /// Verifies that reading a MP3 file without ID3 data results in an absent ID3Tag.
    func testNonTaggedFile() {
        if let url = Bundle(for: type(of: self)).url(forResource: "without-id3", withExtension: "mp3") {
            if let inputStream = InputStream(url: url) {
                TestUtils.expectedAbsentID3Tag(inputStream)
            }
        }
    }

    /// Verifies that reading a MP3 file with an existing ID3 Tag
    func testTaggedFile() {
        if let url = Bundle(for: type(of: self)).url(forResource: "with-some-frames", withExtension: "mp3") {
            if let inputstream = InputStream(url: url) {
                let id3Tag = TestUtils.id3Tag(from: inputstream)

                XCTAssertNotNil(id3Tag)
                XCTAssertGreaterThan(id3Tag!.rawFrames().count, 0)
            } else {
                XCTFail("Could not find file with-some-frames.mp3")
            }
        }
    }
}
