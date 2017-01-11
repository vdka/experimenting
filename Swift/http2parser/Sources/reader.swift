
public enum StreamError : Error {
    case closedStream
    case timeout
}

/*
type Reader struct {
    buf          []byte
    rd           io.Reader // reader provided by the client
    r, w         int       // buf read and write positions
    err          error
    lastByte     int
    lastRuneSize int
}
 
type Reader interface {
    Read(p []byte) (n int, err error)
}
*/


struct Reader {

    func read(_ buffer: inout MutableRawBufferPointer) {
        
    }
}

//public protocol InputStream {
//    var closed: Bool { get }
//    func open(deadline: Double) throws
//    func close()
//
//    func read(into readBuffer: UnsafeMutableBufferPointer<Byte>, deadline: Double) throws -> UnsafeBufferPointer<Byte>
//    func read(upTo byteCount: Int, deadline: Double) throws -> Buffer
//    func read(exactly byteCount: Int, deadline: Double) throws -> Buffer
//}
