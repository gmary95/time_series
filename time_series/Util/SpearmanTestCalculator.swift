import Foundation

class SpearmanTestCalculator {
    var selection: Selection
    var leftovers: [Double]
    
    public init (selection: Selection, leftovers: [Double]) {
        self.selection = selection
        self.leftovers = leftovers
    }
    
    public func CalcDelta() -> [Double] {
        let rankLefovers = SpearmanHelper.rank(leftovers)
        var rankDelta: [Double] = []
        for i in 0 ..< selection.count {
            let delta = rankLefovers[i] - Double(i + 1)
            rankDelta.append(delta)
        }
        return rankDelta
    }
    
    public func CalcRC() -> Double {
        var t = 0.0
        let N = Double(selection.count)
        let c = CalcDelta()
        let sumDelta = SpearmanHelper.sumPow(c)
        let a = 6.0 * sumDelta
        let b = pow(N, 2.0) - 1.0
        t = 1 - (a / (N * b))
        return t
    }
    
    public func CalcS() -> Double {
        var S = 0.0
        let rc = CalcRC()
        let a = rc * sqrt(Double(selection.count - 2))
        let b = sqrt(1.0 - pow(rc, 2.0))
        S = a / b
        return S
    }
    
    func makeDecision(alph: Double)-> (String, Bool) {
        var str = ""
        var isHomoskedastic = false
        let studentQuantil = Quantil.StudentQuantil(p: alph / 2.0, v: Double(selection.count - 2))
        let s = CalcS()
        if s > studentQuantil {
            str = "heteroskedastic, towards to hight"
        } else {
            if s < -studentQuantil {
                str = "heteroskedastic, towards to decrease"
            } else {
                str = "homoskedastic"
                isHomoskedastic = true
            }
        }
        return (str, isHomoskedastic)
    }
}
