import Foundation

class ExploredSet<State: Hashable, Action: Any> {
    private var states: [State: Bool]

    init() {
        self.states = [:]
    }

    func insert(state: State) {
        states[state] = true
    }

    func isStatePresent(state: State) -> Bool {
        return states[state] != nil
    }

    func insertIfNotPresent(state: State) -> Bool {
        if !self.isStatePresent(state: state) {
            states[state] = true
            return true
        } else {
            return false
        }
    }
}
