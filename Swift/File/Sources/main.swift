
let file = File(path: #file)

let buffer = try file.read()

guard let cStr = buffer?.baseAddress?.assumingMemoryBound(to: CChar.self) else { fatalError() }

let str = String(cString: cStr)

print(str)
