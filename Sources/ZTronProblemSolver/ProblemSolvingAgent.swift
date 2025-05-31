import Foundation

public enum ComputationStatus: String, CaseIterable {
    case READY
    case PENDING
    case COMPLETED
    case ERROR
}

open class ProblemSolvingAgent<State: Hashable, Action: Any>: ObservableObject {

    @Published private var status: ComputationStatus
    private var strategy: SolvingStrategy<State, Action>

    public init(strategy: SolvingStrategy<State, Action>) {
        self.strategy = strategy
        self.status = .READY
    }

    open func getStatus() -> ComputationStatus {
        return self.status
    }

    open func setStrategy(strategy: SolvingStrategy<State, Action>) {
        self.strategy = strategy
    }

    open func solve(problem: Problem<State, Action>) throws -> [Action]? {
        var solution: [Action]?
        try self.strategy.reset()

        do {
            Task(priority: .userInitiated) { @MainActor in
                self.status = .PENDING
            }
            
            solution = try strategy.solve(problem: problem)
            
            Task(priority: .userInitiated) { @MainActor in
                self.status = .COMPLETED
            }
        } catch {
            Task(priority: .userInitiated) { @MainActor in
                self.status = .ERROR
            }
        }

        return solution
    }

}
