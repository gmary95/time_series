import Foundation

class DarbinWatsonCalculator {
    var selection: Selection

    public init (selection: Selection) {
        self.selection = selection
    }
    
    public func CalcSumPow() -> Double {
        var sum = 0.0
        for i in 0 ..< selection.count {
            sum += pow(selection[i], 2.0)
        }
        return sum
    }
    
    public func CalcSumDifPow() -> Double {
        var sum = 0.0
        for i in 1 ..< selection.count - 1 {
            sum += pow(selection[i] - selection[i-1], 2.0)
        }
        return sum
    }
    
    public func CalcDW() -> Double {
        var dw = 0.0
        let a = CalcSumDifPow()
        let b = CalcSumPow()
        dw = a / b
        return dw
    }
    
    func chooseDlDu() -> (Double, Double) {
        switch selection.count {
        case 0...6:
            return (0.61, 1.1)
        case 7...10:
            return (0.879, 1.32)
        case 11...20:
            return (1.201, 1.411)
        case 21...40:
            return (1.442, 1.533)
        case 41...75:
            return (1.598, 1.652)
        case 76...100:
            return (1.654, 1.694)
        case 101...150:
            return (1.72, 1.746)
        default:
            return (1.758, 1.778)
        }
    }
    
    func makeDecision()-> String {
        let (dl,du) = chooseDlDu()
        let dw = CalcDW()
        if dw >= du && dw <= (4.0 - du) {
            return "doesn't have autocorrelation"
        }
        if dw >= 0 && dw <= dl {
            return "autocorrelation > 0"
        }
        if dw >= (4.0 - dl) && dw <= 4 {
            return "autocorrelation < 0"
        }
        return "autocorrelation (inf)"
    }
}
