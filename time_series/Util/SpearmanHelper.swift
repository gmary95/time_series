class SpearmanHelper {
    
    public enum RankTieMethod {
        case average
        case min
        case max
        case first
        case last
    }
    
    static func sort(_ values: [Double]) -> [Double] {
        return values.sorted { $0 < $1 }
    }
    
    public static func sum(_ values: [Double]) -> Double {
        return values.reduce(0, +)
    }
    
    public static func frequencies(_ values: [Double]) -> ([Double: Int]) {
        var counts: [Double: Int] = [:]
        
        for item in values {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
        return counts
    }
    
    public static func rank(_ values: [Double], ties: RankTieMethod = .average) -> [Double] {
        var rank: Double
        let start = 1.0
        
        switch ties {
        case .average:
            rank = start - 0.5
        default:
            rank = start - 1.0
        }
        
        var increment: Double
        var tinyIncrement: Double
        let frequencies =  SpearmanHelper.frequencies(values)
        
        var ranks = [Double](repeating: 0, count: values.count)
        
        for value in frequencies.keys.sorted() {
            increment = Double(frequencies[value] ?? 1)
            tinyIncrement = 1.0
            
            for index in 0...(values.count - 1) {
                if value == values[index] {
                    switch ties {
                    case .average:
                        ranks[index] = rank + (increment / 2.0)
                    case .min:
                        ranks[index] = rank + 1
                    case .max:
                        ranks[index] = rank + increment
                    case .first:
                        ranks[index] = rank + tinyIncrement
                        tinyIncrement += 1
                    case .last:
                        ranks[index] = rank + increment - tinyIncrement + 1.0
                        tinyIncrement += 1
                    }
                }
            }
            
            rank += increment
        }
        
        return ranks
    }
}
