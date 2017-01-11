//
//  NewNet.swift
//  NeuralNet
//
//  Created by Ethan Jackwitz on 07/11/2015.
//  Copyright © 2015 Ethan Jackwitz. All rights reserved.
//


import Foundation

//TODO (ethan): Switch to making connections a hashmap alike solution. Dual direction would be good eg.
	//On Individual Neurons
		//(var) Outputs: [Neuron: Connection]
		//(var) Inputs: [Neuron: Connection]
//OR //preffered
	//On the Net itself
		//let Output: [Neuron: [(Neuron, Weights(_connection_))]]
		//let Input: [Neuron: [(Neuron, Weights(_connection_))]]
public class Net {
    public typealias Connection = (weight: Double, deltaWeight: Double)
	
	///The layers of Neurons within the Net
	internal var layers: [[Neuron]] = []
	
	///The transferFunction that the neural net should use.
	private var transferFunction: (Double) -> (Double) = { x in return tanh(x) }
	
	///The derivative of the transfer function the neural net will use.
	private var transferFunctionDerivative: (Double) -> (Double) = { x in return 1.0 - x * x }
	
	///The smoothing factor to use for the recent average error amount
	private var recentAverageSmoothingFactor = 100.0
	
	private var eta: Double = 0.15	//learning rate
	private var alpha: Double = 0.5
	
	///The error amount
	public var error = 0.0
	
	public var recentAverageError = 0.0
	
	public init(layout: [Int]) {
		
		for (layer, nNeurons) in layout.enumerate() {
			
			let nOutputs = layer == layout.count - 1 ? 0 : layout[layer + 1]
			
    		layers.append([])
			for n in 0..<nNeurons {
//				let newNeuron = Neuron(numOutputs: nOutputs)
				let newNeuron = Neuron(numOutputs: nOutputs, location: (layer: layer, n: n))
				
				layers[layer].append(newNeuron)
			}
			print("")
		}
	}
	
	///Gets the current output values from the net.
	public var results: [Double] {
		guard let outputLayer = layers.last else { fatalError("Cannot get results on a net with no layers!") }
		
		return outputLayer.map { neuron in neuron.outputValue }
	}
	
	///Feeds the values foward through the net updating the nets output value(s).
	public func feedForward(inputValues: [Double]) {
		guard let inputLayer = layers.first else { fatalError("Cannot feed foward on a net with no layers!") }
		assert(inputLayer.count == inputValues.count, "Handed wrong number of input values!\nExpected \(layers.first!.count) got \(inputValues.count)")
		
		zip(inputLayer, inputValues).forEach { (inputNeuron, inputValue) in
			inputNeuron.outputValue = inputValue
		}
		
		//for each layer in the net.
		layers.enumerate().forEach { (index, layer) in
			if index == 0 { return } //skip the first layer as it is used for input.
			
			//the previous layer is where the next layers inputs come from.
			let inputLayer = layers[index - 1]
			
			//for each neuron in the current layer
			layer.enumerate().forEach { (neuronIndex, neuron) in
				
				//sum all of the inputs to a neuron
    			let sumOfInputs = inputLayer.reduce(0) { (total, inputNeuron) in
    				total + inputNeuron.outputValue * inputNeuron.outputWeights[neuronIndex].weight
    			}
				
				//run the total of the inputs through the transfer function. This becomes this neurons output.
				neuron.outputValue = transferFunction(sumOfInputs)
			}
		}
	}
	
	public func backPropagate(targetValues: [Double]) {
		guard let outputLayer = layers.last else { fatalError("Cannot back propagate on a net with no layers!") }
		assert(targetValues.count == outputLayer.count, "targetValues contained \(targetValues.count) values, this net has \(outputLayer.count) outputs!")
		
		//Calulate RMS for recentAverageError
		let error = rootMeanSquared(zip(targetValues, outputLayer).map { $0 - $1.outputValue })
		recentAverageError = updateRecentAverageError(error)
		
		//Calculates and sets the gradient for the output neurons
		zip(outputLayer, targetValues).forEach { neuron, targetValue in
			neuron.gradient = calculatedGradient(outputNeuron: neuron, targetValue: targetValue)
		}
		
		//The layers between input and output neurons.
		let hiddenLayers = layers.dropFirst().dropLast()
		
		//For each layer in the hidden layer starting from the end closest to the output layer.
		hiddenLayers.reverse().enumerate().forEach { index, neurons in
			
			let followingLayer = layers.reverse()[index]
			
			//For each neuron in the current layer set the neurons gradient according the the following layer.
			neurons.forEach { neuron in
				neuron.gradient = calculatedGradient(hiddenNeuron: neuron, nextLayersGradients: followingLayer.map({ $0.gradient }))
			}
		}
		
		let updateLayers = layers.dropFirst()
		
		//Update the weights for all layers except the input layer.
		updateLayers.reverse().enumerate().forEach { (layerIndex: Int, layer: [Neuron]) in
			
			//Input layer is the layer to the left of the current one.
			let inputLayer = layers.reverse()[layerIndex + 1]
			
			//For each neuron in the current layer
			//Update the input weights
			layer.enumerate().forEach { (neuronIndex: Int, currentNeuron: Neuron) in
				
				//For each neuron in the input layer update its weights acording to this neurons gradient.
				inputLayer.forEach { inputNeuron in
					
//					inputNeuron.outputWeights[neuronIndex] = updatedNeuronWeights(inputNeuron.outputWeights[neuronIndex], inputValue: inputNeuron.outputValue, gradient: currentNeuron.gradient)
					let oldDeltaWeight = inputNeuron.outputWeights[neuronIndex].deltaWeight
					let newDeltaWeight = eta * inputNeuron.outputValue * currentNeuron.gradient + alpha * oldDeltaWeight
					
					inputNeuron.outputWeights[neuronIndex].deltaWeight = newDeltaWeight
					inputNeuron.outputWeights[neuronIndex].weight += newDeltaWeight
				}
			}
		}
	}
	
	private func updatedNeuronWeights(inputConnection: Connection, inputValue: Double, gradient: Double) -> Connection {
		let newDeltaWeight = inputValue * gradient * eta + alpha * inputConnection.deltaWeight
		
		return Connection(weight: inputConnection.weight + newDeltaWeight, deltaWeight: newDeltaWeight)
	}
	
	private func calculatedGradient(outputNeuron neuron: Neuron, targetValue: Double) -> Double {
		return (targetValue - neuron.outputValue) * transferFunctionDerivative(neuron.outputValue)
	}
	
	private func calculatedGradient(hiddenNeuron neuron: Neuron, nextLayersGradients: [Double]) -> Double {
		assert(neuron.outputWeights.count == nextLayersGradients.count) //TODO (ethan): add message
		
		let sumOfDeltaWeights = zip(neuron.outputWeights, nextLayersGradients).reduce(0.0) { (total, tuple) in
			let (weight, destinationGradient) = (tuple.0.weight, tuple.1)
			return total + weight * destinationGradient
		}
		
		return sumOfDeltaWeights * transferFunctionDerivative(neuron.outputValue)
	}
	
//	private func calculateGradientForHiddenNeuron(outputValue: Double, outputWeights: [Double], nextLayersGradients: [Double]) -> Double {
//		assert(outputWeights.count == nextLayersGradients.count, "got \(outputWeights.count) output weights and \(nextLayersGradients.count) gradients from the next layer!")
//		
//		let zipped = zip(outputWeights, nextLayersGradients)
//		
//		let sumOfDeltaWeights = zipped.reduce(0.0) { (total, tuple) in
//			let (outputWeight, nextLayerGradient) = tuple
//			return total + outputWeight * nextLayerGradient
//		}
//		
//		return sumOfDeltaWeights * transferFunctionDerivative(outputValue)
//	}
//	
	
	private func updateConnectionWeights(connections: [(connection: Connection, gradient: Double, outputValue: Double)]) -> [Connection] {
		
		return connections.map { connection, gradient, outputValue in
			let oldDelta = connection.deltaWeight
			let newDelta = eta * outputValue * gradient + alpha * oldDelta
			return Connection(weight: connection.weight + newDelta, deltaWeight: newDelta)
		}
	}
	
	private func updateRecentAverageError(error: Double) -> Double {
		return (recentAverageError * recentAverageSmoothingFactor + error) / (recentAverageSmoothingFactor + 1.0)
	}
	
	private func rootMeanSquared(values: [Double]) -> Double {
		return sqrt((values.reduce(0.0) { total, value in total + value * value }) / Double(values.count))
	}
}
