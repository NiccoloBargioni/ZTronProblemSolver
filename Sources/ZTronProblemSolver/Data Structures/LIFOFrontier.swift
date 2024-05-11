import Foundation

class LIFOFrontier<State: Hashable, Action: Any>: Frontier<State, Action> {

    private var nodes: [SearchNode<State, Action>]
    private var statesTable: [State: Bool]

    override init() {
        self.nodes = []
        self.statesTable = [:]
        super.init()
    }

    override func isEmpty() throws -> Bool {
        return nodes.count == 0
    }

    override func push(node: SearchNode<State, Action>) throws {
        nodes.append(node)
        self.statesTable[node.getState()] = true
    }

    override func next() throws -> SearchNode<State, Action> {
        let nextNode: SearchNode<State, Action> = self.nodes.last!

        self.nodes.removeLast()
        self.statesTable[nextNode.getState()] = nil

        return nextNode
    }

    override func includes(state: State) throws -> Bool {
        return self.statesTable[state] != nil
    }

}
