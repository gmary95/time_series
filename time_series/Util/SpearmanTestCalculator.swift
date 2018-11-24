import Foundation

class SpearmanTestCalculator {
    var selection: Selection
    var leftovers: Selection
    
    public init (selection: Selection, leftovers: Selection) {
        self.selection = selection
        self.leftovers = leftovers
    }
    
    public func CalcDelta() -> [Double] {
        let rankLefovers = SpearmanHelper.rank(leftovers.data)
        var rankDelta: [Double] = []
        for i in 0 ..< selection.count - 1 {
            let delta = rankLefovers[i] - Double(i + 1)
            rankDelta.append(delta)
        }
        return rankDelta
    }
    
    public func CalcRC() -> Double {
        var t = 0.0
        let N = Double(selection.count)
        let c = CalcDelta()
        let sumDelta = SpearmanHelper.sum(c)
        t = 1 - ((6.0 * sumDelta) / N * (pow(N, 2.0) - 1.0))
        return t
    }
    
    public func CalcS() -> Double {
        var S = 0.0
        let rc = CalcRC()
        let a = rc * sqrt(Double(selection.count - 2))
        let b = 1.0 - pow(rc, 2.0)
        S = a / b
        return S
    }
    
    func makeDecision(alph: Double)-> String {
        var str = ""
        if (abs(CalcS()) <= Quantil.StudentQuantil(p: alph / 2.0, v: Double(selection.count - 2)))
        {
            str = "random"
        }
        else
        {
            if (CalcS() <= -Quantil.StudentQuantil(p: alph / 2.0, v: Double(selection.count - 2))) {
                str = "non-random, towards to hight"
            } else {
                str = "non-random, towards to decrease"
            }
        }
        return str
    }
}
