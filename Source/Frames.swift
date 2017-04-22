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

/// An abstraction for all ID3 Frames.
public protocol ID3Frame {
}

/// A FrameProcessor turns a ID3TagFrame to a ID3Frame.
public protocol FrameProcessor {

    /// Turn a generic ID3TagFrame to a specific  ID3Frame. May return nil oif source ID3TagFrame does not match the
    /// expectations.
    ///
    /// - parameters:
    ///     - id3TagFrame: Will be turned into a ID3Frame.
    ///
    /// - returns: A corresponding ID3Frame or nil
    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame?

    /// Indicator method to find out which ID3 Frame ID is supported by this FrameHProcessor.
    /// - parameters:
    ///     - frameId: 4-Char. Frame Identifier.
    func supports(_ frameId: String) -> Bool
}

/// Singleton holding FrameHProcessors for ID3 Frames.
public final class FrameProcessorRegistry {
    private var handlers: [FrameProcessor]

    private init() {
        handlers = [
                ChapterFrameProcessor(),
                TextInformationFrameProcessor(),
                CommentFrameProcessor(),
                AttachedPictureProcessor()
        ]
    }

    public static let instance = FrameProcessorRegistry()

    /// Register a FrameHProcessor.
    ///
    /// - parameters:
    ///   - processor_ FrameHProcessor to be registered.
    func add(_ processor: FrameProcessor) {
        handlers.append(processor)
    }


    /// Get a FrameProcessor for the given ID3 Frame ID
    ///
    /// - parameters:
    ///      - frameId: ID of the Frame.
    func forFrameId(_ frameId: String) -> FrameProcessor {
        for handler in handlers {
            if (handler.supports(frameId)) {
                return handler
            }
        }
        return DefaultFrameHandler()
    }
}

/// Container for ID3Frames.
public final class Frames {
    public typealias FrameFilter = (_ frame: ID3Frame) -> Bool

    private var frames = [ID3Frame]()

    /// Adds the given ID3Frame
    ///
    /// - parameters:
    ///   - frame: The ID3Frame to add
    func add(_ frame: ID3Frame) {
        frames.append(frame)
    }

    /// Filters available frames with the given FrameFilter
    ///
    /// - parameters:
    ///   - filter: Closure that represents the filter expression.
    ///
    /// - returns: Filtered Frames
    public func filter(_ filter: FrameFilter) -> Frames {
        let filtered = Frames()
        for frame in self.frames {
            if filter(frame) {
                filtered.add(frame)
            }
        }
        return filtered
    }

    /// Get all available Frames for this instance.
    ///
    /// - returns: An array of ID3Frames.
    public func availableFrames() -> [ID3Frame] {
        return frames
    }
}

///  Maps given generic ID3TagFrame to specific ID3Frames.
public final class FrameExtractor {

    /// Maps given generic ID3TagFrame to specific ID3Frames.
    ///
    /// - parameters:
    ///     - frames: ID3TagFrames to be turned into specific ID3Frames.
    ///
    /// - returns: A Frames instance containing mapped ID3Frames.
    public static func extract(_ frames: [ID3TagFrame]) -> Frames {
        return extractWithFailures(frames).extracted
    }


    /// Maps given generic ID3TagFrame to specific ID3Frames.
    ///
    /// - parameters:
    ///   - frames: ID3TagFrames to be turned into specific ID3Frames.
    ///
    /// - returns: A Frames instance containing mapped ID3Frames.
    public static func extractWithFailures(_ frames: [ID3TagFrame]) -> (extracted: Frames, nonExtracted: [ID3TagFrame]) {
        let extractedFrames = Frames()
        var nonExtracted = [ID3TagFrame]()

        for frame in frames {
            if let id3frame = FrameProcessorRegistry.instance.forFrameId(frame.id).from(frame) {
                extractedFrames.add(id3frame)
            } else {
                print("Frame \(frame.id) was not extracted.")
                nonExtracted.append(frame)
            }
        }
        return (extractedFrames, nonExtracted)
    }
}

/// Doing nothing
private final class DefaultFrameHandler: FrameProcessor {

    func from(_ id3tagFrame: ID3TagFrame) -> ID3Frame? {
        return nil
    }

    func supports(_ frameId: String) -> Bool {
        return true
    }
}
