import Foundation

enum DLSError {
    case DLSCutoffException(msg: String)
}

public class DLS<State: Hashable, Action: Any>: SolvingStrategy<State, Action> {
    private var limit: Int

    public init(limit: Int) {
        self.limit = limit
        super.init()
    }

    override func solve(problem: Problem<State, Action>) throws -> [Action]? {
        let rootState = try problem.getInitialState()
        let rootNode = SearchNode<State, Action>.makeRootNode(initialState: rootState)

        let result = try recursiveDLS(problem: problem, node: rootNode, limit: self.limit)
        return result.actions
    }

    private func recursiveDLS( problem: Problem<State, Action>,
                               node: SearchNode<State, Action>,
                               limit: Int) throws -> (actions: [Action]?, cutoff: Bool) {

        if try problem.isGoal(state: node.getState()) {
            var solution: [Action] = []
            var node: SearchNode<State, Action>? = node

            while node != nil {
                if let action = node!.getAction() {
                    solution.append(action)
                }
                node = node?.getParent()
            }

            return (solution.reversed(), false)
        } else {
            if limit == 0 {
                return (nil, true)
            } else {
                var cutoff: Bool = false
                let allActions: [Action] = try problem.getAvailableActions(node: node)

                // swiftlint:disable identifier_name
                for i in 0..<allActions.count {
                    // swiftlint:enable identifier_name
                    let childNode
                        = SearchNode<State, Action>.makeNode(problem: problem, parent: node, action: allActions[i])

                    let result = try recursiveDLS(problem: problem, node: childNode, limit: limit-1)
                    if result.cutoff {
                        cutoff = true
                    } else {
                        if result.actions != nil {
                            return result
                        }
                    }
                } //: FOR

                if cutoff {
                    return (nil, true)
                } else {
                    return (nil, false)
                }
            }//:  ELSE
        }//: ELSE

    }

    override func reset() throws { }
}

var DLSStrategy = DLS<Int, Int>(limit: 4)
