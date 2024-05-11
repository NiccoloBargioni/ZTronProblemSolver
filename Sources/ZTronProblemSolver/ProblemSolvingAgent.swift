import Foundation

public enum ComputationStatus: String, CaseIterable {
    case READY
    case PENDING
    case COMPLETED
    case ERROR
}

public class ProblemSolvingAgent<State: Hashable, Action: Any>: ObservableObject {

    @Published private var status: ComputationStatus
    private var strategy: SolvingStrategy<State, Action>

    public init(strategy: SolvingStrategy<State, Action>) {
        self.strategy = strategy
        self.status = .READY
    }

    public func getStatus() -> ComputationStatus {
        return self.status
    }

    public func setStrategy(strategy: SolvingStrategy<State, Action>) {
        self.strategy = strategy
    }

    public func solve(problem: Problem<State, Action>) throws -> [Action]? {
        var solution: [Action]?
        try self.strategy.reset()

        do {
            self.status = .PENDING
            solution = try strategy.solve(problem: problem)
            self.status = .COMPLETED
        } catch {
            self.status = .ERROR
        }

        return solution
    }

}
