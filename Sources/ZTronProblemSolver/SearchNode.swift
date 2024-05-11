import Foundation
import os

public class SearchNode<State: Hashable, Action: Any>: Hashable {
    private var state: State
    private var action: Action?
    private var parent: SearchNode?
    private var cost: Float
    private var depth: Int

    internal required init(state: State, action: Action?, parent: SearchNode? = nil, cost: Float, depth: Int) {
        self.state = state
        self.action = action
        self.parent = parent
        self.cost = cost
        self.depth = depth
    }

    static func makeNode(problem: Problem<State, Action>, parent: SearchNode, action: Action) -> SearchNode {
        guard let result = try? problem.getResult(
            action: action,
            node: parent
        ) else {
            #if DEBUG
            let logger: Logger = Logger(subsystem: "com.zombietron.problemSolver", category: "SearchNode")
            logger.error("Could not get result for action in \(#function)")
            #endif
            fatalError()
        }

        guard let lastActionCost = try? problem.getCost(
            action: action,
            state: parent.getState()
        ) else {
            #if DEBUG
            let logger: Logger = Logger(subsystem: "com.zombietron.problemSolver", category: "SearchNode")
            logger.error("Could not compute cost for action in \(#function)")
            #endif
            fatalError()
        }

        return SearchNode(
            state: result,
            action: action,
            parent: parent,
            cost: lastActionCost + parent.getCost(),
            depth: parent.getDepth() + 1
        )

    }

    static func makeRootNode(initialState: State) -> SearchNode {
        self.init(state: initialState, action: nil, cost: 0, depth: 0)
    }

    public static func == (lhs: SearchNode<State, Action>, rhs: SearchNode<State, Action>) -> Bool {

        if lhs.getParent() != nil && rhs.getParent() != nil {

            return lhs.parent?.state == rhs.parent?.state &&
                     lhs.state == rhs.state
        } else {
            if lhs.parent == nil && rhs.parent == nil {
                return lhs.state == rhs.state
            } else {
                return false
            }
        }

    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)

        guard let theParent = self.parent else { return }
        hasher.combine(theParent.state)
    }

    public func getState() -> State {
        return self.state
    }

    public func getAction() -> Action? {
        return self.action
    }

    public func getParent() -> SearchNode? {
        return self.parent
    }

    public func getCost() -> Float {
        return self.cost
    }

    public func getDepth() -> Int {
        return self.depth
    }
}
