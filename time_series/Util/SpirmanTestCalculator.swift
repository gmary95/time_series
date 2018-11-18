import Foundation

class SpirmanTestCalculator {
    var selection: Selection
    var h: [[Double]]
    
    public init (selection: Selection) {
        self.selection = selection
        h = Array(repeating: Array(repeating: 0.0, count: selection.count), count: selection.count)
    }
    
    //FIXME: - fix this function to true r(et)
    public func CalcDelta() -> Double {
        for i in 0 ..< selection.count - 1 {
            for j in i + 1 ..< selection.count {
                if (selection[i] < selection[j]) {
                    h[i][j] = 1
                }
                if (selection[i] == selection[j]) {
                    h[i][j] = 0.5
                }
                if (selection[i] > selection[j]) {
                    h[i][j] = 0
                }
            }
        }
        var V = 0.0
        for i in 0 ..< selection.count - 1 {
            for j in i + 1 ..< selection.count {
                V += Double(j-i) * h[i][j]
            }
        }
        return V
    }
        
        public func CalcRC() -> Double {
        var t = 0.0
            let N = Double(selection.count)
        let c = CalcDelta()
        t = 1 - ((6.0 * c) / N * (pow(N, 2.0) - 1.0))
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
