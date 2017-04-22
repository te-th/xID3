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

import Foundation

/// Utility stuff for dealing with some ID3 characteristics
public final class ID3Utils {

    /// Flags indication which encoding is used e.g. in TIT2 frame where
    ///     0 -> Latin1
    ///     3 -> UTF8
    ///     everyting else -> UTF16
    public static let latin1CharsetIndicator = UInt8(0)
    public static let utf8CharsetIndicator = UInt8(3)

    public static let zeroByte = UInt8(0)

    /// Turn the given byte array to a String.
    ///
    /// - parameters:
    ///     - bytes: Array of UInt8s to be turned to a String.
    ///
    /// - returns: The String representation of given bytes.
    public static func toString(_ bytes: [UInt8]) -> String {
        var s = ""
        for b in bytes {
            s.append(Character(UnicodeScalar(b)))
        }
        return s
    }


    /// Determines the tag size. See ID3 header spec. at http://id3.org/id3v2.3.0#ID3v2_header for details.
    ///
    /// - parameters:
    ///     - first: Highest byte
    ///     - second: Second highest byte
    ///     - third: Second lowest byte
    ///     - fourth: Lowest byte
    ///
    /// - returns: (UInt32(first) << 21) + (UInt32(second) << 14) + (UInt32(third) << 7) + UInt32(fourth)
    public static func tagSize(_ first: UInt8, _ second: UInt8, _ third: UInt8, _ fourth: UInt8) -> UInt32 {
        return tagSize(([first, second, third, fourth]))!
    }

    /// Determines the tag size. See ID3 header spec. at http://id3.org/id3v2.3.0#ID3v2_header for details.
    ///
    /// - parameters:
    ///     - bytes: Assuming an array if UInt8 with count == 4.
    ///
    /// - returns: (UInt32(first) << 21) + (UInt32(second) << 14) + (UInt32(third) << 7) + UInt32(fourth)
    public static func tagSize(_ bytes: [UInt8]) -> UInt32? {
        if bytes.count != 4 {
            return nil
        }

        let first = (UInt32(bytes[0]) << 21) + (UInt32(bytes[1]) << 14)
        let second = (UInt32(bytes[2]) << 7) + UInt32(bytes[3])
        return first + second
    }

    /// Determines the frame size. See ID3 frame spec. at http://id3.org/id3v2.3.0#ID3v2_frame_overview for details.
    ///
    /// - parameters:
    ///     - first: Highest byte
    ///     - second: Second highest byte
    ///     - third: Second lowest byte
    ///     - fourth: Lowest byte
    ///
    /// - returns: (UInt32(first) << 24) + (UInt32(second) << 16) + (UInt32(third) << 8) + UInt32(fourth)
    public static func frameSize(_ first: UInt8, _ second: UInt8, _ third: UInt8, _ fourth: UInt8) -> UInt32 {
        return frameSize([first, second, third, fourth])!
    }

    /// Determines the frame size. See ID3 frame spec. at http://id3.org/id3v2.3.0#ID3v2_frame_overview for details.
    ///
    /// - parameters:
    ///     - first: Highest byte
    ///     - second: Second highest byte
    ///     - third: Second lowest byte
    ///     - fourth: Lowest byte
    ///
    /// - returns: (UInt32(first) << 24) + (UInt32(second) << 16) + (UInt32(third) << 8) + UInt32(fourth)
    public static func frameSize(_ bytes: [UInt8]) -> UInt32? {

        let first = (UInt32(bytes[0]) << 24) + (UInt32(bytes[1]) << 16)
        let second = (UInt32(bytes[2]) << 8) + UInt32(bytes[3])
        return first + second
    }

    /**
        Derives String.Encoding from given byte where ID3Utils#latin1CharsetIndicator indicates Latin1 and
        ID3Utils#utf8CharsetIndicator indicates UTF8 encoding. Defaults to UTF16.

        @param byte The encoding indicator

        @returns The mapped String.Encoding
    **/
    public static func encodingFrom(_ byte: UInt8) -> String.Encoding {
        let encoding: String.Encoding

        switch(byte) {
        case ID3Utils.latin1CharsetIndicator:
            encoding = String.Encoding.isoLatin1
        case ID3Utils.utf8CharsetIndicator:
            encoding = String.Encoding.utf8
        default:
            encoding = String.Encoding.utf16
        }
        return encoding
    }

    /// Get the next n bytes from an ArraySlice<UInt8> and return them as an Array of bytes
    ///
    /// - parameters:
    ///     - content: An ArraySlice<UInt8>. Inout parameter, will be mutated in this method.
    ///     - nextNBytes: The amout if bytes to get
    ///
    /// - returns: The next n bytes as an Array of bytes
    public static func nextBytes(_ content: inout ArraySlice<UInt8>, nextNBytes: Int) -> [UInt8] {
        var buffer = [UInt8]()
        var i = 0
        while i < nextNBytes && content.first != nil {
            buffer.append(content.popFirst()!)
            i += 1
        }
        return buffer
    }

    /// Move forward in given ArraySlice<UInt8> sequence as long as there are zero bytes
    ///
    /// - parameters:
    ///     - content: The ArraySlice<UInt8> to skip zero bytes for.
    public static func skipZeroBytes(_ content: inout ArraySlice<UInt8>) {
        while content.first != nil && content.first! == UInt8(0){
            content = content.dropFirst()
        }
    }
}
