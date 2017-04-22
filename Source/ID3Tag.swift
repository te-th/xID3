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


/// Represents the ID3 Tag
public final class ID3Identifier {
    private let lenId = 3
    private let lenVersion = 2
    private let lenFlags = 1
    private let lenSize = 4
    private let lenExtendedHeader = 4

    public static let V3 = UInt8(3)

    static let id = "ID3"
    public let version: ID3Version
    public let size: UInt32

    /// Indicates that ID3 Tag has an extended header
    public let extendedHeader: Bool

    private let a_flag_comparator = UInt8(1) << 7
    private let b_flag_comparator = UInt8(1) << 6
    private let c_flag_comparator = UInt8(1) << 5

    /// Create an optional ID3Identifier instance from the given InputStream. Ignores Extended Header.
    ///
    /// - parameters:
    ///     - stream: An InputStream that may contain an ID3 Tag
    ///
    init? (_ stream: InputStream) {

        var identifier = [UInt8](repeating: 0, count: lenId)

        stream.read(&identifier, maxLength: lenId)

        if ID3Identifier.id != ID3Utils.toString(identifier) {
            return nil
        }

        var version = [UInt8](repeating: 0, count: lenVersion)
        stream.read(&version, maxLength: lenVersion)
        self.version = ID3Version(version[0], version[1])

        if self.version.major != ID3Identifier.V3 {
            return nil
        }

        var flag = [UInt8](repeating: 0, count: lenFlags)
        stream.read(&flag, maxLength: lenFlags)
        self.extendedHeader = (flag[0] & b_flag_comparator) == UInt8(1)

        var size = [UInt8](repeating: 0, count: lenSize)
        stream.read(&size, maxLength: lenSize)
        self.size = ID3Utils.tagSize(size[0], size[1], size[2], size[3])

        if extendedHeader {
            var extendedHeaderSizeBuffer = [UInt8](repeating: 0, count: lenExtendedHeader)
            stream.read(&extendedHeaderSizeBuffer, maxLength: lenExtendedHeader)
            let extendedHeaderSize = ID3Utils.tagSize(size[0], size[1], size[2], size[3])

            var dump = [UInt8](repeating: 0, count: Int(extendedHeaderSize) - lenExtendedHeader)
            stream.read(&dump, maxLength: dump.count)
        }
    }
}

/// Represents the content of an ID3 Tag
final class ID3Content {
    private let lenId = 4
    private let lenSize = 4
    private let lenFlag = 2

    private var availableFrames = [ID3TagFrame]()

    /// Read ID3 Frames from the given InputStream.
    ///
    /// - parameters:
    ///     - stream: The InputStream containing ID3 Information.
    ///     - size: Size of the ID3 Tag.
    init(_ stream: InputStream, _ size: UInt32) {
        var i = UInt32(0)

        while i < size {
            var frameIdBuffer = [UInt8](repeating: 0, count: lenId)
            stream.read(&frameIdBuffer, maxLength: lenId)
            let frameId = ID3Utils.toString(frameIdBuffer)

            var sizeBuffer = [UInt8](repeating: 0, count: lenSize)
            stream.read(&sizeBuffer, maxLength: lenSize)
            let frameSize = ID3Utils.frameSize(sizeBuffer[0], sizeBuffer[1], sizeBuffer[2], sizeBuffer[3])

            if frameSize == 0 {
                break
            }

            var flagBuffer = [UInt8](repeating: 0, count: lenFlag)
            stream.read(&flagBuffer, maxLength: lenFlag)

            var contentBuffer = [UInt8](repeating: 0, count: Int(frameSize))
            stream.read(&contentBuffer, maxLength: contentBuffer.count)

            let frame = ID3TagFrame(id: frameId, size: frameSize, content: contentBuffer, flags: flagBuffer)

            availableFrames.append(frame)

            i += UInt32(lenId + lenSize + lenFlag) + frameSize
        }
    }

    /// Get the available ID3 Frames.
    ///
    /// - returns: The available ID3 Frames.
    public func rawFrames() -> [ID3TagFrame] {
        return self.availableFrames
    }
}

/// Represents a ID3 Frame.
public struct ID3TagFrame {
    let id: String
    let size: UInt32
    let content: [UInt8]
    let flags: [UInt8]
}

/// Represents the ID3 Version.
public final class ID3Version {
    let major: UInt8
    let minor: UInt8

    init(_ major: UInt8, _ minor: UInt8) {
        self.major = major
        self.minor = minor
    }
}

/// An ID3 Tag consisting of an ID3Identifier and the avaikable Frames.
public struct ID3Tag {
    let identifier: ID3Identifier
    private let content: ID3Content

    init(_ identifier: ID3Identifier, _ content: ID3Content) {
        self.identifier = identifier
        self.content = content
    }

    /// Return the available ID3 Frames.
    ///
    /// - returns: The available ID3 Frames.
    public func rawFrames() -> [ID3TagFrame] {
        return content.rawFrames()
    }
}

/// Utility type extracting an ID3Tag from a given InputStream. Right not ID3v3 is supported.
public final class ID3Reader {

    /// Extracts an ID3Tag from a given InputStream.
    ///
    /// - parameters:
    ///     - stream An InputStream that may contain ID3 information.
    ///
    /// - return: An optional ID3Tag
    public static func read(_ stream: InputStream) -> ID3Tag? {
        let id = ID3Identifier(stream)
        guard let identifier = id else {
            return nil
        }

        let content = ID3Content(stream, identifier.size)
        return ID3Tag(identifier, content)
    }
}
