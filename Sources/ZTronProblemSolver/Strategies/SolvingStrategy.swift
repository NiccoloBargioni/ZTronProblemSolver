import Foundation

public class SolvingStrategy<State: Hashable, Action: Any> {

    public init() {  }

    func solve(problem: Problem<State, Action>) throws -> [Action]? {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }

    func reset() throws {
        throw ProblemError.OperationNotImplementedException(msg: "Default implementation invoked")
    }
}
