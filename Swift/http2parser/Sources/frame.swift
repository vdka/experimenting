
typealias UInt24 = (UInt16, UInt8)

func numericCast(_ value: UInt32) -> UInt24 {
    return (UInt16((value & 0x00FFFF00) >> 8), UInt8((value & 0x000000FF)))
}

func numericCast(_ value: UInt24) -> UInt32 {
    return (UInt32(value.0) << 8) + UInt32(value.1)
}

typealias Byte = UInt8

struct Frame {

    var header: Header

    enum FrameType: UInt8 {
        case data         = 0x0
        case headers      = 0x1
        case priority     = 0x2
        case rstStream    = 0x3
        case settings     = 0x4
        case pushPromise  = 0x5
        case ping         = 0x6
        case goAway       = 0x7
        case windowUpdate = 0x8
        case continuation = 0x9

        static let names: [StaticString] = ["DATA", "HEADERS", "PRIORITY", "RST_STREAM", "SETTINGS", "PUSH_PROMISE", "PING", "GOAWAY", "WINDOW_UPDATE", "CONTINUATION"]
        var name: StaticString {
            return FrameType.names[numericCast(rawValue)]
        }

        var description: String {
            return name.description
        }

        var flagNames: [Frame.Flag: String] {
            switch self {
            case .data:         return [.dataEndStream: "END_STREAM", .dataPadded: "PADDED"]
            case .headers:      return [.headersEndStream: "END_STREAM", .headersEndHeaders: "END_HEADERS", .headersPadded: "PADDED", .headersPriority: "PRIORITY"]
            case .settings:     return [.settingsAck: "ACK"]
            case .ping:         return [.pingAck: "ACK"]
            case .continuation: return [.continuationEndHeaders: "END_HEADERS"]
            case .pushPromise:  return [.pushPromiseEndHeaders: "END_HEADERS", .pushPromisePadded: "PADDED"];
            default:            return [:]
            }
        }

        init(_ byte: Byte) throws {
            guard let type = FrameType(rawValue: byte) else {
                throw Error.invalid
            }

            self = type
        }
    }


    struct Header {

        /*
         https://tools.ietf.org/html/rfc7540#section-4.1
         +-----------------------------------------------+
         |                 Length (24)                   |
         +---------------+---------------+---------------+
         |   Type (8)    |   Flags (8)   |
         +-+-------------+---------------+-------------------------------+
         |R|                 Stream Identifier (31)                      |
         +=+=============================================================+
         |                   Frame Payload (0...)                      ...
         +---------------------------------------------------------------+
        */

        /// Length is the length of the frame, not including the 9 byte header.
        /// The maximum size is one byte less than 16MB (uint24), but only
        /// frames up to 16KB are allowed without peer agreement.
        let length: UInt24
        var isValid: Bool

        // Type is the 1 byte frame type. There are ten standard frame
        // types, but extension frame types may be written by WriteRawFrame
        // and will be returned by ReadFrame (as UnknownFrame).
        let type: FrameType

        /// Flags are the 1 byte of 8 potential bit flags per frame.
        /// They are specific to the frame type.
        let flags: Flag

        // StreamID is which stream this frame is for. Certain frames
        // are not stream-specific, in which case this field is 0.
        let streamId: UInt32
    }

    struct Flag: OptionSet, Hashable {
        var rawValue: UInt8
        init(rawValue: UInt8) { self.rawValue = rawValue }

        // Frame-specific FrameHeader flag bits.
        // Data Frame
        static let dataEndStream = Flag(rawValue: 0x1)
        static let dataPadded    = Flag(rawValue: 0x8)

        // Headers Frame
        static let headersEndStream  = Flag(rawValue: 0x1)
        static let headersEndHeaders = Flag(rawValue: 0x4)
        static let headersPadded     = Flag(rawValue: 0x8)
        static let headersPriority   = Flag(rawValue: 0x20)

        // Settings Frame
        static let settingsAck = Flag(rawValue: 0x1)

        // Ping Frame
        static let pingAck = Flag(rawValue: 0x1)

        // Continuation Frame
        static let continuationEndHeaders = Flag(rawValue: 0x4)
        static let pushPromiseEndHeaders  = Flag(rawValue: 0x4)
        static let pushPromisePadded      = Flag(rawValue: 0x8)

        var hashValue: Int { return numericCast(rawValue) }
    }

    enum Error: Swift.Error {
        case invalid
        case tooLarge
    }

    static let parsers: [(Header, [Byte]) throws -> Frame] = [

    ]

    // func parseDataFrame(frameHeader: Header, payload: [Byte]) {
    //
    // }

    static let headerLength: UInt32 = 9
    static var maxFrameSize: UInt32 = 16_777_215 // (2^24 - 1) octets
    static func readFrameHeader(from: Reader, to buffer: RawBufferPointer) throws -> Header {
        let length   = buffer.load(fromByteOffset: 0, as: UInt24.self)
        let typeRaw  = buffer.load(fromByteOffset: 3, as: UInt8.self)
        let flagsRaw = buffer.load(fromByteOffset: 4, as: UInt8.self)
        let streamId = buffer.load(fromByteOffset: 5, as: UInt32.self) & 0x7FFFFFFF // mask the reserved bit.

        guard numericCast(length) < Frame.maxFrameSize else { throw Error.tooLarge }

        let type = try FrameType(typeRaw)
        let flags = Flag(rawValue: flagsRaw)
        return Header(length: length, isValid: true, type: type, flags: flags, streamId: streamId)
    }
}


/// Reads and writes frames
struct Framer {
    var lastFrame: Frame?
    var error: Frame.Error?

    var lastHeaderStream: UInt32

    var headerBuffer: (UInt64, UInt8) // 9 bytes static inline.

    var maxReadSize: UInt32
    var readBuffer: [Byte]

    var maxWriteSize: UInt32
    var writeBuffer: [Byte]

    var maxHeaderListSize: UInt32
}

extension Framer {

    mutating func startWrite(type: Frame.FrameType, flags: Frame.Flag, streamId: UInt32) {
        var streamId = streamId // shouldn't copy as it's not actually mutated.
        writeBuffer.append(0)
        writeBuffer.append(0)
        writeBuffer.append(0)
        writeBuffer.append(type.rawValue)
        writeBuffer.append(flags.rawValue)
        withUnsafeBytes(of: &streamId) { writeBuffer.append(contentsOf: $0) }
    }

    mutating func endWrite() throws {
        let length: UInt32 = numericCast(writeBuffer.count) - Frame.headerLength
        guard length < (1 << 24) else {
            throw Frame.Error.tooLarge
        }

        var length24: UInt24 = numericCast(length)
        withUnsafeBytes(of: &length24) {
            writeBuffer[0] = $0[0]
            writeBuffer[1] = $0[1]
            writeBuffer[2] = $0[2]
        }

        // TODO(vdka): Write to output
    }
}

extension Framer {

    mutating func writeByte(_ byte: Byte) {
        writeBuffer.append(byte)
    }

    mutating func writeBytes<S: Sequence>(_ bytes: S)
        where S.Iterator.Element == Byte
    {
        writeBuffer.append(contentsOf: bytes)
    }
}

extension Framer {

    mutating func readFrame(r: Reader) throws -> Frame {
        // clear the last error
        self.error = nil

        lastFrame?.header.isValid = false


    }
}
