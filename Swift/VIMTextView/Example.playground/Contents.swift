//: Playground - noun: a place where people can play

import Cocoa

struct GapBuffer {
  
  class Buffer {
    
    var basePointer: UnsafeMutableBufferPointer<UTF8.CodeUnit>
    var firstBuffer: UnsafeMutableBufferPointer<UTF8.CodeUnit>
    var gapBuffer: UnsafeMutableBufferPointer<UTF8.CodeUnit>
    var secondBuffer: UnsafeMutableBufferPointer<UTF8.CodeUnit>
    
    init(capacity: Int) {

    }
  }
  
}
