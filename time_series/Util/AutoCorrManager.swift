class AutoCorrManager {
    var dw: Double
    
    public init (dw: Double) {
        self.dw = dw
    }
    
    func calculateAlph() -> Double {
        return 1.0 - (dw / 2.0)
    }
}
