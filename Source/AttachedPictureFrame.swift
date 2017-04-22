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

/// Represents the attached Picture, APIC frame
public struct AttachedPictureFrame : ID3Frame {
    public let mimetype: String?
    public let type: UInt8?
    public let desc: String?
    public let imageData: [UInt8]

    init(mimetype: String?, type: UInt8?, description: String?, imageData: [UInt8]) {
        self.mimetype = mimetype
        self.type = type
        self.desc = description
        self.imageData = imageData
    }
}


/// Implements the Attached Picture Frame APIC regarding this spec.
/// <Header for 'Attached picture', ID: "APIC">
///   Text encoding   $xx
///   MIME type       <text string> $00
///   Picture type    $xx
///   Description     <text string according to encoding> $00 (00)
///   Picture data    <binary data>
final class AttachedPictureProcessor : FrameProcessor {

    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame? {

        var content = ArraySlice(id3tagFrame.content)

        let encoding = ID3Utils.encodingFrom(content.popFirst()!)

        var mimetypeBuffer = [UInt8]()
        while content.first != nil && content.first! != ID3Utils.zeroByte {
            mimetypeBuffer.append(content.popFirst()!)
        }
        let mimetype = String(bytes: mimetypeBuffer, encoding: String.Encoding.utf8)

        content = content.dropFirst()

        let pictureType = content.popFirst()

        var descriptionBuffer = [UInt8]()
        while content.first != nil && content.first! != ID3Utils.zeroByte {
            descriptionBuffer.append(content.popFirst()!)
        }
        let description = String(bytes: descriptionBuffer, encoding: encoding)

        var pictureBuffer = [UInt8]()
        content.forEach({pictureBuffer.append($0)})

        return AttachedPictureFrame(mimetype: mimetype, type: pictureType, description: description, imageData: pictureBuffer)
    }

    func supports(_ frameId: String) -> Bool {
        return "APIC" == frameId
    }
}

