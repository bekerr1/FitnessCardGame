//
//  SwiftQueue.swift
//  LewisWorkout
//
//  Created by brendan kerr on 7/7/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import Foundation
import UIKit

protocol QueueType {
    
    associatedtype Element
    mutating func enqueue(element: Element)
    mutating func dequeue() -> Element?
    
}



struct ShapeQueue<T: Shapeable> : QueueType, ExpressibleByArrayLiteral {
    
    typealias Element = T
    private var left : [Element]
    private var right: [Element]
    
    
    init () {
        left = []
        right = []
    
    }
    
    init(arrayLiteral elements: Element...) {
        
        left = []
        right = []
        
        populateQueueWithArr(contents: elements)
    }
    
    init(WithArray contents: [Element]) {
        left = []
        right = []
        
        populateQueueWithArr(contents: contents)
    }
    
    /// Add an element to the back of the queue in O(1).
    mutating func enqueue(element: Element) {
        
        right.append(element)
    }
    
    /// Removes front of the queue in amortized O(1).
    mutating func dequeue() -> Element? {
        
        /// Returns nil in case of an empty queue.
        guard !( left.isEmpty && right.isEmpty) else { return nil }
        
        if left.isEmpty {
            left = right.reversed()
            right.removeAll(keepingCapacity: true)
        }
        
        return left.removeLast()
        
    }
    
    func queueContents() -> [Element] {
        
        return left + right.reversed()
    }
    
    mutating func populateQueueWithArr(contents: [Element]) {
        
        for element in contents {
            enqueue(element: element)
        }
    }
    
}
    

struct DetectionQueue<T : Equatable> : QueueType, ExpressibleByArrayLiteral {
    
    typealias Element = T
    private var left : [Element]
    private var right: [Element]
    
    
    init () {
        left = []
        right = []
        
    }
    
    init(arrayLiteral elements: Element...) {
        
        left = []
        right = []
        
        populateQueueWithArr(contents: elements)
    }
    
    init(WithArray contents: [Element]) {
        left = []
        right = []
        
        populateQueueWithArr(contents: contents)
    }
    
    /// Add an element to the back of the queue in O(1).
    mutating func enqueue(element: Element) {
        
        if let previousElement = right.last {
            if element != previousElement {
                right.append(element)
            }
        } else {
            right.append(element)
        }
    }
    
    /// Removes front of the queue in amortized O(1).
    mutating func dequeue() -> Element? {
        
        /// Returns nil in case of an empty queue.
        guard !( left.isEmpty && right.isEmpty) else { return nil }
        
        if left.isEmpty {
            left = right.reversed()
            right.removeAll(keepingCapacity: true)
        }
        
        return left.removeLast()
        
    }
    
    func queueContents() -> [Element] {
        
        return left + right.reversed()
    }
    
    mutating func populateQueueWithArr(contents: [Element]) {
        
        for element in contents {
            enqueue(element: element)
        }
    }
    
    
//    mutating func uniqueify() {
//        left = Array(Set(left))
//        right = Array(Set(right))
//    }
    
}

