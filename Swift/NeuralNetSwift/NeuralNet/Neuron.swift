import Foundation

public class Neuron: Hashable, Equatable {
	///The calculated Gradient value
	public var gradient: Double = 0.0
	
	///Represents a _connection_ between two neurons
	public typealias Connection = (weight: Double, deltaWeight: Double)
	
	///The weights of the cennections leaving the Neuron
	public var outputWeights: [Connection] = []
	
	///The value being output by the Neuron
	public var outputValue: Double = 0.0
	
	public var location: (layer: Int, n: Int)
	
	///Hash key
	public var hashValue: Int {
		return Int("\(location.layer)\(location.n)")!
	}
	
	public init(numOutputs: Int, weight: Double = Double.random(0, 1), location: (layer: Int, n: Int)) {
		self.location = location
		(0..<numOutputs).forEach { _ in
			outputWeights.append(Connection(weight: weight, deltaWeight: 0.0))
		}
		
		print("Made a Neuron! location: \(hashValue)")
	}
}

public func ==(lhs: Neuron, rhs: Neuron) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

