import Foundation

public final class UniformCost<State: Hashable, Action: Any>: SolvingStrategy<State, Action> {
    private var aStar: AStar<State, Action>

    override public init() {
        self.aStar = AStar(heuristic: { _ in
            return Float(0)
        })
        super.init()
    }

    override func solve(problem: Problem<State, Action>) throws -> [Action]? {
        let solution = try aStar.solve(problem: problem)
        return solution
    }

    override func reset() throws {
        try self.aStar.reset()
    }

    public func getOptimalSolutionCost() -> Float? {
        return self.aStar.getOptimalSolutionCost()
    }

}

