
import Darwin.C

typealias Byte = UInt8

protocol Reader {
    func read() throws -> UnsafeRawBufferPointer?
}

protocol Writer {
    func write(_ bytes: UnsafeRawBufferPointer) throws -> UInt
}

class File {

    let path: String

    fileprivate var fildes: Int32?

    init(path: String) {
        self.path = path
    }

    enum Error: Swift.Error {
        case insuficientPermissions
        case unknown
    }
}

extension File: Reader {

    func read() throws -> UnsafeRawBufferPointer? {

        var fileStats = UnsafeMutablePointer<Darwin.stat>.allocate(capacity: 1)
        defer { fileStats.deallocate(capacity: 1) }

        let err = Darwin.stat(path, fileStats)
        if err != 0 { return nil }

        fildes = Darwin.open(path, Darwin.O_RDONLY)
        guard let fildes = fildes, fildes != -1 else {
            switch Darwin.errno {
            case Darwin.EACCES: throw Error.insuficientPermissions
            default: throw Error.unknown
            }
        }
        defer {
            _ = Darwin.close(fildes)
            self.fildes = nil
        }

        let fileSize = Int(fileStats.pointee.st_size)

        let bytes = UnsafeMutableRawPointer.allocate(bytes: fileSize, alignedTo: 1)

        let bytesRead = Darwin.read(fildes, bytes, fileSize)
        guard bytesRead != -1 else { throw Error.unknown }
        assert(bytesRead == fileSize)

        let buffer = UnsafeRawBufferPointer(start: bytes, count: fileSize)
        return buffer
    }
}
