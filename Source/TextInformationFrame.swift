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

/// The TextInformation Frame
public struct TextInformationFrame : ID3Frame {
    public let text: String?
    public let frameId: String
    
    init(_ id: String, _ text: String?) {
        self.frameId = id
        self.text = text
    }
}

/// Processing Text Information Frames such as "TIT2", "TYER", "TPE1", "TALB", "TPUB", "TIT3", "TCON", "TCOP", "TENC"
final class TextInformationFrameProcessor: FrameProcessor {
    
    private let supportedFrames = ["TIT2", "TYER", "TPE1", "TALB", "TPUB", "TIT3", "TCON", "TCOP", "TENC"]
    
    func supports(_ frameId: String) -> Bool {
        return supportedFrames.contains(frameId)
    }

    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame? {
        if id3tagFrame.content.count < 2 {
            return nil
        }
        return toId3Frame(id3tagFrame)
    }

    private func toId3Frame(_ id3tagFrame: ID3TagFrame) -> ID3Frame {
        var content = ArraySlice(id3tagFrame.content)
        let encoding = ID3Utils.encodingFrom(content.popFirst()!)

        let text = String(data: Data(bytes: content), encoding: encoding)

        return TextInformationFrame(id3tagFrame.id, text)
    }
}
