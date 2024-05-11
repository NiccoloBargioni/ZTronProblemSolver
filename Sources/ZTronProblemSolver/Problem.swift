import Foundation

enum ProblemError: Error {
    // swiftlint:disable identifier_name
    case OperationNotImplementedException(msg: String)
    // swiftlint:enable identifier_name
}

open class Problem<State: Hashable, Action: Any> {

    public init() {  }

    open func getInitialState() throws -> State {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked" )
    }

    open func getAvailableActions(node: SearchNode<State, Action>) throws -> [Action] {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked" )
    }

    open func getResult(action: Action, node: SearchNode<State, Action>) throws -> State {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked" )
    }

    open func isGoal(state: State) throws -> Bool {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked" )
    }

    open func getCost(action: Action, state: State) throws -> Float {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked" )
    }
}
