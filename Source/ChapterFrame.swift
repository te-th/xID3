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


/// The CHAP Frame.
public struct ChapterFrame: ID3Frame {
    public let startTime: UInt32
    public let endTime: UInt32
    public let startOffset: UInt32
    public let endOffset: UInt32
    public let subFrame: ID3Frame?

    init(startTime: UInt32, endTime: UInt32, startOffset: UInt32, endOffset: UInt32, subFrame: ID3Frame?) {
        self.startTime = startTime
        self.endTime = startTime
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.subFrame = subFrame
    }
}

/// Extracts a ChapterFrame from the given ID3 CHAP Frame. A CHAP frame is encoded as
/// <ID3v2.3 or ID3v2.4 frame header, ID: "CHAP">           (10 bytes)
/// Element ID      <text string> $00
/// Start time      $xx xx xx xx
/// End time        $xx xx xx xx
/// Start offset    $xx xx xx xx
/// End offset      $xx xx xx xx
/// <Optional embedded sub-frames>
final class ChapterFrameProcessor: FrameProcessor {

    private let handlingFrameId = "CHAP"
    private let lenPositions = 4

    func supports(_ frameId: String) -> Bool {
        return frameId == handlingFrameId
    }

    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame? {
        var content = ArraySlice(id3tagFrame.content)

        var elementIdBuffer = [UInt8]()
        while content.first != nil && content.first! != ID3Utils.zeroByte {
            elementIdBuffer.append(content.popFirst()!)
        }
        content = content.dropFirst()

        let startTime = ID3Utils.frameSize(ID3Utils.nextBytes(&content, nextNBytes: lenPositions))!
        let endTime = ID3Utils.frameSize(ID3Utils.nextBytes(&content, nextNBytes: lenPositions))!

        let startOffset = ID3Utils.frameSize(ID3Utils.nextBytes(&content, nextNBytes: lenPositions))!
        let endOffset = ID3Utils.frameSize(ID3Utils.nextBytes(&content, nextNBytes: lenPositions))!

        let subFrameId = String(bytes: ID3Utils.nextBytes(&content, nextNBytes: lenPositions), encoding: String.Encoding.utf8)
        let subFrameSize = ID3Utils.frameSize(ID3Utils.nextBytes(&content, nextNBytes: lenPositions))!

        content = content.dropFirst().dropFirst()

        var subFrameContent = [UInt8]()
        content.forEach({subFrameContent.append($0)})

        let subFrameProcessor = FrameProcessorRegistry.instance.forFrameId(subFrameId!)

        let subFrame =
                subFrameProcessor.from(
                        ID3TagFrame(
                                id: subFrameId!,
                                size: subFrameSize,
                                content: subFrameContent,
                                flags: [UInt8(0)]))

        return ChapterFrame(
                startTime: startTime,
                endTime: endTime,
                startOffset: startOffset,
                endOffset: endOffset,
                subFrame: subFrame)
    }
}
