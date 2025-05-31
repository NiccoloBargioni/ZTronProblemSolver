import XCTest
@testable import ZTronProblemSolver

final class ZTronProblemSolverTests: XCTestCase {
    func testForwardSearch() throws {
        let agent = ProblemSolvingAgent(strategy: DLS<AlphaOmegaProblemState, Generator>(limit: 4))
        let problem = AlphaOmegaSwitchesProblem(
            colors: [.green, .red, .green, .red, .green, .green],
            switches: [
                Generator(location: .storage, state: .down),
                Generator(location: .solitary, state: .down),
                Generator(location: .generators, state: .up),
                Generator(location: .beds, state: .up),
                Generator(location: .diner, state: .up),
                Generator(location: .lounge, state: .down),
            ]
        )
        
        if let solution = try? agent.solve(problem: problem) {
            if solution.count <= 0 {
                print("INITIAL STATE IS ALREADY SOLUTION")
            } else {
                for generator in solution {
                    print(generator.getLocation())
                }
            }
        } else {
            print("NO SOLUTION FOUND WITHIN DEPTH \(4)")
        }
        
    }
    
    
    func testReverseProblem() throws {
        let agent = ProblemSolvingAgent(strategy: BFS<AlphaOmegaProblemState, Generator>())
        let problem = AlphaOmegaReverseSwitchesProblem(targetColors: [.green, .green, .green, .green, .green, .green])
         // RGGGGR
        
        if let solution = try? agent.solve(problem: problem) {
            for generator in solution {
                print(generator.toString())
            }
        } else {
            print("NO SOLUTION FOUND WITHIN DEPTH \(4)")
        }

    }
    
    func testBacktracking() throws {
        let allPossibleOutputs = combine(6, 4)
        assert(allPossibleOutputs.count == 15)
        
        for draw in allPossibleOutputs {
            var reds = [ButtonColor].init(repeating: .green, count: 6)
            var greens = [ButtonColor].init(repeating: .red, count: 6)
            
            for index in draw {
                reds[index] = .red
                greens[index] = .green
            }
            
            let redsAsString = reds.reduce("") { redsString, buttonColor in
                return redsString + buttonColor.rawValue
            }
            let greensAsString = reds.reduce("") { greensString, buttonColor in
                return greensString + buttonColor.rawValue
            }

            print("\(redsAsString) | \(greensAsString)")
        }
    }
    
    
    func testBinaryGeneration() throws {
        assert(generateBinaries(6).count == 1 << 6)
    }
    
    
    func testGenerateAllPossibleInitialGenerators() throws {
        let allLocations = Location.allCases
        
        let allStates = generateBinaries(6)
        let allGeneratorsStates = allStates.enumerated().map { i, state in
            return state.enumerated().map { j, bit in
                return Generator(location: allLocations[j], state: bit == 0 ? .down : .up)
            }
        }
        
        let allPossibleDraws = combine(6, 4)
        var allFeasibleInitialStates: [AlphaOmegaProblemState] = []

        
        for draw in allPossibleDraws {
            var reds = [ButtonColor].init(repeating: .green, count: 6)
            var greens = [ButtonColor].init(repeating: .red, count: 6)
                        
            for index in draw {
                reds[index] = .red
                greens[index] = .green
            }

            
            for generatorState in allGeneratorsStates {
                let redAgent = ProblemSolvingAgent(strategy: BFS<AlphaOmegaProblemState, Generator>())
                let greenAgent = ProblemSolvingAgent(strategy: BFS<AlphaOmegaProblemState, Generator>())
                
                let redsInitialState = AlphaOmegaProblemState(colors: reds, switches: generatorState)
                let greensInitialState = AlphaOmegaProblemState(colors: greens, switches: generatorState)
                
                let redProblem = AlphaOmegaSwitchesProblem(initialState: redsInitialState)
                if let redsSolution = try? redAgent.solve(
                    problem: redProblem
                ) {
                    if !redProblem.isUnexpected {
                        allFeasibleInitialStates.append(redsInitialState)
                    }
                }
                
                let greenProblem = AlphaOmegaSwitchesProblem(initialState: greensInitialState)
                if let greensSolution = try? greenAgent.solve(
                    problem: greenProblem
                ) {
                    if !greenProblem.isUnexpected {
                        allFeasibleInitialStates.append(greensInitialState)
                    }
                }
            }
        }
        
        
        print(allFeasibleInitialStates.count)
        
        var duplicatesCount: Int = 0
        for i in 0..<allFeasibleInitialStates.count {
            for j in i+1..<allFeasibleInitialStates.count {
                if allFeasibleInitialStates[i].colorsString == allFeasibleInitialStates[j].colorsString {
                    duplicatesCount += 1
                }
            }
        }
        
        print(duplicatesCount)
    }
}

internal enum Location: String, Hashable, Sendable, CaseIterable {
    case beds
    case diner
    case generators
    case storage
    case solitary
    case lounge
}

internal enum GeneratorState: String, Hashable, Sendable {
    case up
    case down
    
    public func toggled() -> GeneratorState {
        return self == .up ? .down : .up
    }
}

internal enum ButtonColor: String, Hashable, Sendable {
    case red = "r"
    case green = "g"
    
    public func toggled() -> ButtonColor {
        return self == .red ? .green : .red
    }
}


internal final class Generator: Hashable, Sendable, CustomStringConvertible {
    var description: String {
        return self.toString()
    }
    
    private let location: Location
    private let state: GeneratorState
    
    public init(location: Location, state: GeneratorState) {
        self.location = location
        self.state = state
    }
    
    static func == (lhs: Generator, rhs: Generator) -> Bool {
        return lhs.location == rhs.location && lhs.state == rhs.state
    }
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(location)
    }

    
    internal final func getLocation() -> Location {
        return self.location
    }
    
    internal final func getSwitchState() -> GeneratorState {
        return self.state
    }
    
    public final func getMutableCopy() -> Generator.WritableDraft {
        return WritableDraft(owner: self)
    }
    
    internal final class WritableDraft {
        weak private var owner: Generator?
        private var state: GeneratorState
        
        public init(owner: Generator) {
            self.owner = owner
            self.state = owner.state
        }
        
        public final func toggle() -> Self {
            self.state = self.state.toggled()
            return self
        }
        
        public final func getImmutableCopy() -> Generator {
            guard let owner = self.owner else { fatalError("failed to retain reference to object of type \(String(describing: Generator.self))") }
            return Generator(location: owner.location, state: self.state)
        }
        
        internal final func getLocation() -> Location {
            guard let owner = self.owner else { fatalError("failed to retain reference to object of type \(String(describing: Generator.self))") }
            return owner.location
        }
        
        internal final func getSwitchState() -> GeneratorState {
            return self.state
        }

    }
    
    public static func makeGenerators(for colors: [ButtonColor]) -> [Generator] {
        assert(colors.count == 6)
        
        let numberOfReds = colors.reduce(0) { countOfReds, buttonColor in
            if buttonColor == .red {
                return countOfReds + 1
            } else {
                return countOfReds
            }
        }
        
        let numberOfGreen = colors.reduce(0) { numberOfGreens, buttonColor in
            if buttonColor == .green {
                return numberOfGreens + 1
            } else {
                return numberOfGreens
            }
        }
        
        assert(numberOfReds == 4 || numberOfGreen == 4)
        
        let stringRepresentation = colors.reduce("") { colorsString, currentColor in
            return colorsString + currentColor.rawValue
        }
        
        switch stringRepresentation {
            case "rgrrrg":
            return [
                Generator(location: .storage, state: .down),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .down),
            ]
            
        case "grrggg":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .down),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .down),
            ]

        case "rrggrr":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .down),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .up),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .up),
            ]

        case "ggggrr":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .up),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .down),
            ]

        case "gggrrg":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .down),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .up),
                Generator(location: .lounge, state: .up),
            ]

        case "rgrggg":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .up),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .up),
            ]

        case "grgrgg":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .up),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .down),
            ]

        case "rrgggg":
            return [
                Generator(location: .storage, state: .down),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .up),
                Generator(location: .lounge, state: .up),
            ]

            
        case "grrrgr":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .up),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .up),
                Generator(location: .lounge, state: .up),
            ]
            
            
        case "rggggr":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .up),
                Generator(location: .lounge, state: .down)
            ]
            
        case "gggrgr":
            return [
                Generator(location: .storage, state: .down),
                Generator(location: .solitary, state: .up),
                Generator(location: .generators, state: .down),
                Generator(location: .beds, state: .up),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .up)
            ]
            
        case "rggrgg":
            return [
                Generator(location: .storage, state: .up),
                Generator(location: .solitary, state: .down),
                Generator(location: .generators, state: .up),
                Generator(location: .beds, state: .down),
                Generator(location: .diner, state: .down),
                Generator(location: .lounge, state: .up)
            ]
            
        default:
            fatalError("unknow initial combination")
        }
        
    }
    
    public final func toString() -> String {
        return """
        Generator(
            location: \(location.rawValue),
            state: \(state.rawValue)
        )
        """
    }
}


internal final class AlphaOmegaProblemState: Hashable, Sendable {
    private let colors: [ButtonColor]
    private let switches: [Generator]
    
    internal var colorsString: String {
        return self.colors.reduce("") { colorsString, buttonColor in
            return colorsString + buttonColor.rawValue
        }
    }
    
    
    internal var generatorsString: String {
        return self.switches.reduce("") { partialGensString, nextGenerator in
            return partialGensString + "(\(nextGenerator.getLocation().rawValue), \(nextGenerator.getSwitchState().rawValue),"
        }.dropLast().toString()
    }
    
    // FIXME: DOESN'T ACCOUNT FOR SWITCHES
    static func == (lhs: AlphaOmegaProblemState, rhs: AlphaOmegaProblemState) -> Bool {
        let lhsColors = lhs.colors.reduce("") { colorsString, buttonColor in
            return colorsString + buttonColor.rawValue
        }
        
        let rhsColors = rhs.colors.reduce("") { colorsString, buttonColor in
            return colorsString + buttonColor.rawValue
        }
        
        return lhsColors == rhsColors
    }

    internal func hash(into hasher: inout Hasher) {
        hasher.combine(colorsString)
        //hasher.combine(generatorsString)
    }
    
    public init(colors: [ButtonColor], switches: [Generator]) {
        self.colors = colors
        self.switches = switches
    }
    
    public final func getColors() -> [ButtonColor] {
        var clone = [ButtonColor].init()
        
        for color in self.colors {
            clone.append(color)
        }
        
        return clone
    }
    
    public final func getSwitches() -> [Generator] {
        var clone = [Generator].init()
        
        for generator in self.switches {
            clone.append(generator)
        }
        
        return clone
    }
    
    internal final func getMutableCopy() -> AlphaOmegaProblemState.WritableDraft {
        return AlphaOmegaProblemState.WritableDraft.init(owner: self)
    }
    
    internal final class WritableDraft {
        weak private var owner: AlphaOmegaProblemState?
        private var colors: [ButtonColor]
        private var switches: [Generator]
        
        private var colorsDidChange: Bool = false
        private var switchesDidChange: Bool = false
        
        public init(owner: AlphaOmegaProblemState) {
            self.owner = owner
            self.colors = owner.colors
            self.switches = owner.switches
        }
        
        public final func updatingColors(produce: @escaping (inout [ButtonColor]) -> Void) -> Self {
            var clone = [ButtonColor].init()
            
            for color in self.colors {
                clone.append(color)
            }
            
            produce(&clone)
            
            self.colors = clone
            self.colorsDidChange = true
            return self
        }
        
        public final func updatingGenerators(produce: @escaping (inout [Generator.WritableDraft]) -> Void) -> Self {
            var clone = [Generator.WritableDraft].init()
            
            for generator in self.switches {
                clone.append(generator.getMutableCopy())
            }
            
            produce(&clone)
            
            self.switches = clone.map { generator in
                return generator.getImmutableCopy()
            }
            
            self.switchesDidChange = true
            return self
        }
        
        public final func getImmutableCopy() -> AlphaOmegaProblemState {
            guard let owner = self.owner else { fatalError("Failed to retain reference to object of type \(String(describing: AlphaOmegaProblemState.self))") }
            guard self.colorsDidChange || self.switchesDidChange else {
                return owner
            }
            
            return AlphaOmegaProblemState(
                colors: self.colorsDidChange ? self.colors : owner.colors,
                switches: self.switchesDidChange ? self.switches : owner.switches
            )
        }
    }
    
}


internal final class AlphaOmegaSwitchesProblem: Problem<AlphaOmegaProblemState, Generator> {
    private let initialState: AlphaOmegaProblemState
    private let expected: [Location : GeneratorState] = [
        .beds: .up,
        .diner: .up,
        .generators: .up,
        .storage: .down,
        .solitary: .down,
        .lounge: .down
    ]
    
    private(set) internal var isUnexpected: Bool = false
    
    public init(colors: [ButtonColor]) {
        self.initialState = AlphaOmegaProblemState(
            colors: colors,
            switches: Generator.makeGenerators(for: colors)
        )
    }
    
    internal init(colors: [ButtonColor], switches: [Generator]) {
        self.initialState = AlphaOmegaProblemState(colors: colors, switches: switches)
    }

    internal init(initialState: AlphaOmegaProblemState) {
        self.initialState = initialState
    }
    
    override internal func getInitialState() throws -> AlphaOmegaProblemState {
        return self.initialState
    }

    override internal func getAvailableActions(node: SearchNode<AlphaOmegaProblemState, Generator>) throws -> [Generator] {
        return node.getState().getSwitches().map { generator in
            return generator.getMutableCopy().toggle().getImmutableCopy()
        }
    }

    override internal func getResult(action: Generator, node: SearchNode<AlphaOmegaProblemState, Generator>) throws -> AlphaOmegaProblemState {
        switch action.getLocation() {
        case .beds:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[1] = colors[1].toggled()
                    colors[2] = colors[2].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .diner:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[2] = colors[2].toggled()
                    colors[3] = colors[3].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .generators:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[2] = colors[2].toggled()
                    colors[3] = colors[3].toggled()
                    colors[4] = colors[4].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .storage:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[4] = colors[4].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .solitary:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[1] = colors[1].toggled()
                    colors[3] = colors[3].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .lounge:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[1] = colors[1].toggled()
                    colors[4] = colors[4].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        }
    }

    override internal func isGoal(state: AlphaOmegaProblemState) throws -> Bool {
        let returnValue = state.getColors().reduce(true) { allGreen, buttonColor in
            return allGreen && buttonColor == .green
        }
    
        if returnValue {
            let generators = state.getSwitches()
            
            var isExpected: Bool = true
            for generator in generators {
                if !isExpected { break }
                isExpected = isExpected && generator.getSwitchState() == self.expected[generator.getLocation()]!
            }
            
            if !isExpected {
                self.isUnexpected = true
            }
        }
        
        return returnValue
    }

    override internal func getCost(action: Generator, state: AlphaOmegaProblemState) throws -> Float {
        return 1.0
    }
}


func combine(_ n: Int, _ k: Int) -> [[Int]] {
    var result: [[Int]] = []
    var combination: [Int] = []

    func backtrack(_ start: Int) {
        // Base case: if combination is of length k, add to result
        if combination.count == k {
            result.append(combination)
            return
        }

        // Iterate through the elements starting from `start`
        for i in start..<n {
            combination.append(i)
            backtrack(i + 1)  // move to the next element
            combination.removeLast()  // backtrack
        }
    }

    backtrack(0)
    return result
}


public func generateBinaries(_ n: Int) -> [[Int]] {
    var output: [[Int]] = .init()
    
    for i in 0..<(1 << n) {
        var iAsBinary: [Int] = .init(repeating: .zero, count: n)
        
        var remainder: Int = i
        let bitCount: Int = i > 0 ? Int(ceil(log2(Double(i + 1)))) : 0
        var j = bitCount
        
         while remainder >= 1 {
             let bit = remainder % 2
             remainder = remainder/2
             iAsBinary[n - bitCount + j - 1] = bit
             j -= 1
         }
        
        output.append(iAsBinary)
    }
    
    return output
}


internal final class AlphaOmegaReverseSwitchesProblem: Problem<AlphaOmegaProblemState, Generator> {
    private let targetColors: [ButtonColor]

    public init(targetColors: [ButtonColor]) {
        self.targetColors = targetColors
    }

    override internal func getInitialState() throws -> AlphaOmegaProblemState {
        return AlphaOmegaProblemState(
            colors: .init(repeating: .green, count: 6),
            switches: [
                Generator(location: .beds, state: .up),
                Generator(location: .diner, state: .up),
                Generator(location: .generators, state: .up),
                
                Generator(location: .storage, state: .down),
                Generator(location: .solitary, state: .down),
                Generator(location: .lounge, state: .down),
            ]
        )
    }

    override internal func getAvailableActions(node: SearchNode<AlphaOmegaProblemState, Generator>) throws -> [Generator] {
        return node.getState().getSwitches().map { generator in
            return generator.getMutableCopy().toggle().getImmutableCopy()
        }
    }

    override internal func getResult(action: Generator, node: SearchNode<AlphaOmegaProblemState, Generator>) throws -> AlphaOmegaProblemState {
        switch action.getLocation() {
        case .beds:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[1] = colors[1].toggled()
                    colors[2] = colors[2].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .diner:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[2] = colors[2].toggled()
                    colors[3] = colors[3].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .generators:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[2] = colors[2].toggled()
                    colors[3] = colors[3].toggled()
                    colors[4] = colors[4].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .storage:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[4] = colors[4].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .solitary:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[1] = colors[1].toggled()
                    colors[3] = colors[3].toggled()
                    colors[5] = colors[5].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()

        case .lounge:
            return node.getState()
                .getMutableCopy()
                .updatingColors { colors in
                    colors[0] = colors[0].toggled()
                    colors[1] = colors[1].toggled()
                    colors[4] = colors[4].toggled()
                }
                .updatingGenerators { generators in
                    let indexOfGen = generators.firstIndex { draft in
                        return draft.getLocation() == action.getLocation()
                    }
                    
                    if let indexOfGen = indexOfGen {
                        generators[indexOfGen] = action.getMutableCopy()
                    }
                }
                .getImmutableCopy()
        }
    }

    override internal func isGoal(state: AlphaOmegaProblemState) throws -> Bool {
        return zip(state.getColors(), self.targetColors).reduce(true) { equals, comparables in
            return equals && comparables.0 == comparables.1
        }
    }

    override internal func getCost(action: Generator, state: AlphaOmegaProblemState) throws -> Float {
        return 1.0
    }
}


fileprivate extension String.SubSequence {
    func toString() -> String {
        return String(self)
    }
}
