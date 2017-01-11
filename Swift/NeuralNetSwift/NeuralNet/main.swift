#!/usr/bin/env xcrun swift

import Foundation

struct DataSet {
	let nInputs: Int
	let nOutputs: Int
	let combine: (Int, Int) -> Int
	
	init(nInputs: Int = 2, nOutputs: Int = 1, combine: (Int, Int) -> Int = (^)) {
		self.nInputs = nInputs
		self.nOutputs = nOutputs
		self.combine = combine
	}
	
	var dataSample: (inputs: [Double], output: Double) {
		let inputs = (0..<nInputs).map { _ in Int.random(0, 1) }
//		let output = inputs.reduce(0, combine: { previous, next in combine(previous, next) })
//		
//		return (inputs: inputs.map({ Double($0) }), output: Double(output))
		
		return (inputs: inputs.map({ Double($0) }), output: Double(1))
	}
}

func runTwoOneData(dataSet: DataSet, n: Int = 1000, net: Net, successMargin: Double = 0.01) -> Int {
	
	var hits = 0
	
    for i in 1...n {
		let data = dataSet.dataSample
		
    	net.feedForward(data.inputs)
    	
    	let results = net.results
		
		if results[0] <= data.output - successMargin || results[0] >= data.output + successMargin {
			hits++
		}
    	
    	net.backPropagate([data.output])
		
    	let df = "%.2f"
    	let a = String(format: df, data.inputs[0])
    	let b = String(format: df, data.inputs[1])
    	let t = String(format: df, data.output)
    	let r = String(format: df, results[0])
    	let rae = String(format: df, net.recentAverageError)
    	print("pass: \(i)\n\(a) \(b) -> \(t)\nRAE: \(rae) -> \(r)\n")
    }
	
	return hits
}

//let oldnet = Net(layout: [2, 2, 1])
let net = Net(layout: [2, 2, 1])

let dataSet = DataSet(nInputs: 2, nOutputs: 1, combine: (max))

print(runTwoOneData(dataSet, n: 200, net: net))


print("Done")
