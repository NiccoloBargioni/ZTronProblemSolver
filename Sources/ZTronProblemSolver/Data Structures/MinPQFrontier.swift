import Foundation

class MinPQFrontier<State: Hashable, Action: Any>: Frontier<State, Action> {

    private var nodes: [SearchNode<State, Action>]
    private var statesTable: [State: Int]
    private var priority: (SearchNode<State, Action>) -> Float

    init( priority: @escaping (SearchNode<State, Action>) -> Float ) {
        self.nodes = []
        self.statesTable = [:]
        self.priority = priority
        super.init()
    }

    override func isEmpty() throws -> Bool {
        return nodes.count == 0
    }

    override func push(node: SearchNode<State, Action>) throws {
        self.statesTable[node.getState()] = self.nodes.count-1
        self.nodes.append(node)
        self.bubbleUp(start: self.nodes.count-1)
    }

    override func next() throws -> SearchNode<State, Action> {
        let minPriorityNode = self.nodes.first!
        self.statesTable[self.nodes.first!.getState()] = nil

        self.nodes[0] = self.nodes.last!
        self.statesTable[self.nodes.last!.getState()] = 0

        self.nodes.removeLast()
        self.bubbleDown(start: 0)

        return minPriorityNode
    }

    override func includes(state: State) throws -> Bool {
        return self.statesTable[state] != nil
    }

    // swiftlint:disable identifier_name
    private func getParent(of: Int) -> Int? {
        // swiftlint:enable identifier_name
        if of == 0 {
            return nil
        } else {
            if of % 2 != 0 {
                return (of-1)/2
            } else {
                return (of-2)/2
            }
        }
    }

    // swiftlint:disable identifier_name
    private func leftChild(of: Int) -> Int {
        // swiftlint:enable identifier_name
        return 2*of+1
    }

    // swiftlint:disable identifier_name
    private func rightChild(of: Int) -> Int {
        // swiftlint:enable identifier_name
        return 2*of+2
    }

    private func hasLeftChild(who: Int) -> Bool {
        return leftChild(of: who) < self.nodes.count
    }

    private func hasRightChild(who: Int) -> Bool {
        return rightChild(of: who) < self.nodes.count
    }

    private func bubbleUp(start: Int) {
        var theParent: Int? = getParent(of: start)
        var theNode: Int = start

        while theParent != nil &&
               priority(self.nodes[theParent!]) > priority(self.nodes[theNode]) {

            swap(theNode, theParent!)
            theNode = theParent!
            theParent = getParent(of: theParent!)
        }
    }

    private func bubbleDown(start: Int) {
        var theNode: Int = start

        while hasLeftChild(who: theNode) {
            let leftChild: Int = leftChild(of: theNode)

            if hasRightChild(who: theNode) {
                let rightChild: Int = rightChild(of: theNode)

                let minValue: Int =
                    ( self.priority(self.nodes[leftChild]) < self.priority(self.nodes[rightChild]) ) ?
                        leftChild : rightChild

                let minPriority = self.priority(self.nodes[minValue])

                if self.priority(self.nodes[theNode]) < minPriority {
                    break
                } else {
                    swap(theNode, minValue)
                    theNode = minValue
                }
            } else {
                if self.priority(self.nodes[theNode]) > self.priority(self.nodes[leftChild]) {
                    swap(theNode, leftChild)
                    theNode = leftChild
                } else {
                    break
                }
            }
        }

    }

    func pushIfBetter(node: SearchNode<State, Action>) throws {
        if try !self.includes(state: node.getState()) {
            return try self.push(node: node)
        } else {
            let formerNode = self.nodes[self.statesTable[node.getState()]!]
            let formerNodePos = self.statesTable[node.getState()]!

            if self.priority(node) < self.priority(formerNode) {
                self.statesTable[formerNode.getState()] = nil
                self.nodes[formerNodePos] = self.nodes.last!
                self.statesTable[self.nodes.last!.getState()] = formerNodePos
                self.nodes.removeLast()
                self.bubbleDown(start: formerNodePos)
                try self.push(node: node)
            }

        }
    }

    // swiftlint:disable identifier_name
    private func swap(_ a: Int, _ b: Int) {
        // swiftlint:enable identifier_name
        let temp = self.nodes[a]
        self.nodes[a] = self.nodes[b]
        self.nodes[b] = temp

        self.statesTable[self.nodes[a].getState()] = a
        self.statesTable[self.nodes[b].getState()] = b
    }

    func printAll() {
        // swiftlint:disable identifier_name
        print(self.nodes.map { n in
            // swiftlint:enable identifier_name
            return n.getState()
        })
    }

}
