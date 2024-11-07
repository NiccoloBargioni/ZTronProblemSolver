import Foundation

public final class AStar<State: Hashable, Action: Any>: SolvingStrategy<State, Action> {
    private var frontier: MinPQFrontier<State, Action>
    private var explored: ExploredSet<State, Action>
    private var heuristic: (SearchNode<State, Action>) -> Float
    private var latestOptimalSolutionCost: Float?

    public init(heuristic: @escaping (SearchNode<State, Action>) -> Float) {
        self.heuristic = heuristic
        self.frontier = MinPQFrontier(priority: { node in
            node.getCost() + heuristic(node)
        })
        self.explored = ExploredSet()
        super.init()
    }

    override func solve(problem: Problem<State, Action>) throws -> [Action]? {
        let root = SearchNode<State, Action>.makeRootNode(initialState: try problem.getInitialState())
        try self.frontier.push(node: root)

        while try !self.frontier.isEmpty() {
            let nextNode = try self.frontier.next()
            let nextState = nextNode.getState()

            if try problem.isGoal(state: nextNode.getState()) {
                var solution: [Action] = []
                var node: SearchNode<State, Action>? = nextNode

                while node != nil {
                    if let action = node!.getAction() {
                        solution.append(action)
                    }
                    node = node?.getParent()
                }

                self.latestOptimalSolutionCost = nextNode.getCost()
                return solution.reversed()
            } else {
                _ = self.explored.insertIfNotPresent(state: nextState)
                let allActions: [Action] = try problem.getAvailableActions(node: nextNode)

                // swiftlint:disable identifier_name
                for i in 0..<allActions.count {
                    // swiftlint:enable identifier_name
                    let thisChild
                        = SearchNode<State, Action>.makeNode(problem: problem, parent: nextNode, action: allActions[i])
                    let thisChildState = thisChild.getState()

                    if try !self.explored.isStatePresent(state: thisChildState)
                        && !self.frontier.includes(state: thisChildState) {
                        try self.frontier.push(node: thisChild)
                    } else {
                        if try self.frontier.includes(state: thisChildState) {
                            try self.frontier.pushIfBetter(node: thisChild)
                        }
                    }

                }
            }
        }

        return nil
    }

    override func reset() throws {
        self.frontier = MinPQFrontier(priority: { node in
            node.getCost() + self.heuristic(node)
        })
        self.explored = ExploredSet()
        self.latestOptimalSolutionCost = nil
    }

    public func getOptimalSolutionCost() -> Float? {
        return self.latestOptimalSolutionCost
    }
}
