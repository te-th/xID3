<img src="logo.png" width="250" />

[![Build Status](https://travis-ci.org/te-th/xID3.svg?branch=fix%2Fvisibility)](https://travis-ci.org/te-th/xID3)

# xID3
xID3s purpose is to provide a model to extract ID3 Tag information from a
series of bytes. It´s written in Swift and supports reading ID3v2.3 information
right now.

xID3 aims to be an extendable, easy to use Framework to work with Id3 Tags.

## Design
xID3 comes with two main components.

### ID3Tag
An ID3Tag contains "raw" information on ID3. "Raw" means that it does not know
anything about the structure of certain ID3 Frames such as TIT2, APIC, COMM etc.
It simply knows how to read ID3 Information (defined at http://id3.org/) and
provides them as a _ID3Tag_ instances.

An _ID3Tag_ is a composition of an _ID3Identifier_ and a collection of
_ID3TagFrame_s. _ID3Identifier_ represents the header information from an ID3
Tag, _ID3TagFrame_ represents ID3 Frames as "raw data":
```
struct ID3TagFrame {
    let id: String // Frame Id, e.g. TIT2, APIC, etc
    let size: UInt32 // Size of the Frames content
    let content: [UInt8] // Frames content as raw bytes
    let flags: [UInt8] // ID3 Frame tags
}
```

### Frames Processing
_ID3TagFrame_  instances can be converted to _ID3Frame_ instances.
_ID3Frame_ are implementations of specific ID3 Frames such as TIT2, API, COMM
etc. They expose frames data by dedicated type members.

 Conversion can be done using a _FrameProcessor_. Such a _FrameProcessor_ takes a _ID3TagFrame_ and converts it to a  _ID3Frame_.

## Supported Frames
- TIT2
- TYER
- TPE1
- TALB
- TPUB
- TIT3
- TCON
- TCOP
- TENC
- COMM
- APIC
- CHAP

## License
Licensed under Apache License, Version 2.0.
