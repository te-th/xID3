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

extension ID3TagFrame : CustomStringConvertible {
    public var description: String {
        get {
            return "id: \(id), size: \(size), content: \(content), flags: \(flags)"
        }
    }
}

extension ID3Version : CustomStringConvertible {
    public var description: String {
        get {
            return "major: \(major), minor: \(minor)"
        }
    }
}

extension TextInformationFrame: CustomStringConvertible {
    public var description: String {
        get {
            return "ID: \(frameId), text: \(text)"
        }
    }
}

extension CommentFrame: CustomStringConvertible {
    public var description: String {
        get {
            return "ID: COMM, lang: \(language), short comment: \(shortComment), comment: \(comment)"
        }
    }
}

extension AttachedPictureFrame: CustomStringConvertible {
    public var description: String {
        get {
            return "ID: ATIC, mime-type: \(mimetype), picture-type: \(type), description: \(self.desc). \(imageData.count) Bytes"
        }
    }
}

if CommandLine.arguments.count < 2 {
    print("Please specify an MP3 file you want to get ID3 Tag Information for.")
    exit(-1)
}

let file = CommandLine.arguments[1]
let inputStream = InputStream(fileAtPath: file)

guard let inputStream = inputStream else {
    print("Unable to open \(file) for reading")
    exit(0)
}

inputStream.open()
if let id3tag = ID3Reader.read(inputStream) {
    print("ID3 identified. Version: (\(id3tag.identifier.version)), Size: \(id3tag.identifier.size) bytes")
    let frames: Frames = FrameExtractor.extract(id3tag.rawFrames())
    for frame in frames.filter({$0 is TextInformationFrame }).availableFrames() {
        print(frame)
    }

    for frame in frames.filter({$0 is CommentFrame }).availableFrames() {
        print(frame)
    }

    for frame in frames.filter({$0 is ChapterFrame }).availableFrames() {
        print(frame)
    }

    for frame in frames.filter({$0 is AttachedPictureFrame}).availableFrames() {
        print(frame)
    }
}
else {
    print("ID3v2.3 was not extracted")
}
inputStream.close()
