import Foundation

public final class IterativeDeepening<State: Hashable, Action: Any>: SolvingStrategy<State, Action> {
    private var limit: Int

    public init(limit: Int = Int.max) {
        self.limit = limit
        super.init()
    }

    override func solve(problem: Problem<State, Action>) throws -> [Action]? {
        guard !(try problem.isGoal(state: problem.getInitialState())) else { return [] }

        // swiftlint:disable identifier_name
        for i in 0..<limit {
            // swiftlint:enable identifier_name
            let DLS = DLS<State, Action>(limit: i)
            let result = try DLS.solve(problem: problem)

            if result != nil {
                return result
            }
        }

        return nil
    }

    override func reset() throws { }
}
