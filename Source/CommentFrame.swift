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

/// Represents a CommentFrame COMM
public struct CommentFrame : ID3Frame {
    public let shortComment: String?
    public let comment: String?
    public let language: String?

    init(language: String?, shortComment: String?, _ comment: String?) {
        self.language = language
        self.shortComment = shortComment
        self.comment = comment
    }
}

/// Extracts a CommentFrame from the given ID3 COMM Frame. A COMM frame is encoded as
/// <Header for 'Comment', ID: "COMM">
/// Text encoding           $xx
/// Language                $xx xx xx
/// Short content descrip.  <text string according to encoding> $00 (00)
/// The actual text         <full text string according to encoding>
final class CommentFrameProcessor: FrameProcessor {

    func supports(_ frameId: String) -> Bool {
        return "COMM" == frameId
    }

    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame? {
        var content = ArraySlice(id3tagFrame.content)

        let encoding = ID3Utils.encodingFrom(content.popFirst()!)
        // next three bytes after encoding flag represents the language
        let language = String(bytes: ID3Utils.nextBytes(&content, nextNBytes: 3), encoding: String.Encoding.utf8)

        let shortCmt = shortComment(&content, encoding: encoding)

        ID3Utils.skipZeroBytes(&content)

        let cmt = comment(&content, encoding: encoding)

        return CommentFrame(language: language, shortComment: shortCmt, cmt)
    }

    private func shortComment(_ content: inout ArraySlice<UInt8>, encoding: String.Encoding) -> String? {
        var shortCommentBytes = [UInt8]()
        while content.first != nil && content.first! != UInt8(0) {
            shortCommentBytes.append(content.popFirst()!)
        }
        content = content.dropFirst()
        return String(bytes: shortCommentBytes, encoding: encoding)
    }

    private func comment(_ content: inout ArraySlice<UInt8>, encoding: String.Encoding) -> String? {
        var commentBytes = [UInt8]()
        while content.first != nil {
            commentBytes.append(content.popFirst()!)
        }
        return String(bytes: commentBytes, encoding: encoding)
    }
}
