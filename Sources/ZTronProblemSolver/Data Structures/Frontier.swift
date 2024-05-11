import Foundation

class Frontier<State: Hashable, Action: Any> {

    internal init() {  }

    func isEmpty() throws -> Bool {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }

    func push(node: SearchNode<State, Action>) throws {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }

    func next() throws -> SearchNode<State, Action> {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }

    func includes(state: State) throws -> Bool {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }

}
