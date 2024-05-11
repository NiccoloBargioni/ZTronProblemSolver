import Foundation

public class BFS<State: Hashable, Action: Any>: SolvingStrategy<State, Action> {
    private var frontier: FIFOFrontier<State, Action>
    private var explored: ExploredSet<State, Action>

    override public init() {
        self.frontier = FIFOFrontier()
        self.explored = ExploredSet()
        super.init()
    }

    override func solve(problem: Problem<State, Action>) throws -> [Action]? {
        let root = SearchNode<State, Action>.makeRootNode(initialState: try problem.getInitialState())
        try self.frontier.push(node: root)

        while try !self.frontier.isEmpty() {
            let nextNode = try self.frontier.next()
            let nextState = nextNode.getState()

            _ = self.explored.insertIfNotPresent(state: nextState)
            let allActions: [Action] = try problem.getAvailableActions(node: nextNode)

            // swiftlint:disable identifier_name
            for i in 0..<allActions.count {
                // swiftlint:enable identifier_name
                let thisChild
                    = SearchNode<State, Action>.makeNode(problem: problem, parent: nextNode, action: allActions[i])
                let thisChildState = thisChild.getState()

                if try problem.isGoal(state: thisChild.getState()) {
                    var solution: [Action] = []
                    var node: SearchNode<State, Action>? = thisChild

                    while node != nil {
                        if let action = node!.getAction() {
                            solution.append(action)
                        }
                        node = node?.getParent()
                    }

                    return solution.reversed()
                } else {
                    if try !self.explored.isStatePresent(state: thisChildState)
                            && !self.frontier.includes(state: thisChildState) {
                        try self.frontier.push(node: thisChild)
                    }
                }

            }
        }

        return nil
    }

    override func reset() throws {
        self.frontier = FIFOFrontier()
        self.explored = ExploredSet()
    }
}
