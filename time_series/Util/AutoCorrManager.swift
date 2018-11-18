class AutoCorrManager {
     var selection: Selection
    var dw: Double
    
    public init (selection: Selection, dw: Double) {
        self.selection = selection
        self.dw = dw
    }
    
    func calculateAlph() -> Double {
        return 1.0 - (dw / 2.0)
    }
}
