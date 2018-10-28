import Foundation

struct Interval {
    public var min: Double
    public var max: Double
}

struct Characteristic {
    public var value: Double
    public var standartDeviation: Double
    public var confidenceInterval: Interval
}

struct  QuantitativeCharacteristics {
    public var arithmeticMean: Characteristic
    public var variance: Characteristic
    public var skewness: Characteristic
    public var kurtosis: Characteristic
}

class Selection {
    private var data: Array<Data> {
        get{
            return self.data
        }
        set {
            data = newValue
        }
    }
    private var count: Int {
        get{
            return self.count
        }
        set {
            count = newValue
        }
    }
    private var order: Int {
        get{
            return self.order
        }
        set {
            order = newValue
        }
    }
    
    init() {
        self.data = Array<Data>()
        self.count = 0
        self.order = 1
    }
    
    init(order: Int, capacity: Int)
    {
        if order < 1 {
            print("Order should be an integer number greater than zero!")
        }
        
        self.data = Array<Data>()
        self.count = capacity
        self.order = order
        
        for i in 0 ..< self.count {
            data.append(Data(length: order))
        }
    }
    
    
    subscript(index: Int) -> Data {
        get
        {
            if ((index >= 0) && (index < self.count)) {
                return (self.data[index])
            } else {
                print("Ivalid index!")
            }
        }
        set
        {
            if ((index >= 0) && (index < self.count) && (newValue.count == order)) {
                data[index] = newValue
            }
        }
    }
    
    
    public func append() {
        data.append(Data(length: order))
        
        count += 1
    }
    
    public func append(item: Data) {
        if (item.count != order) {
            print("Invalid order of item!")
        }
        
        data.append(item)
        
        count += 1
    }
    
    public func arithmeticMean() -> Double {
        var result: Double
        var sum: Double
        
        sum = 0
        for item in data {
            sum += item[0]
        }
        
        result = sum / Double(data.count)
        
        return result
    }
    
    public func variance() -> Double {
        var result: Double
        var sum: Double
        var arithMeam: Double
        
        arithMeam = arithmeticMean()
        
        sum = 0
        for item in data {
            sum += pow((item[0] - arithMeam), 2)
        }
        
        result = sum / Double((data.count - 1))
        
        return (result);
    }
    
    private func _variance() -> Double {
        var result: Double
        var sum: Double
        var arithMeam: Double
        
        arithMeam = arithmeticMean()
        
        sum = 0
        for item in data {
            sum += pow(item[0], 2) - pow(arithMeam, 2)
        }
        
        result = sum / Double(data.count)
        
        return result
    }
    
    public func Skewness() -> Double {
        var result: Double
        var sum: Double
        var arithMeam: Double
        var variance: Double
        var _a: Double
        
        arithMeam = arithmeticMean()
        variance = pow(_variance(), 1.0 / 2.0)
        
        sum = 0
        for item in data {
            sum += pow((item[0] - arithMeam), 3.0)
        }
        
        _a = sum / (Double(data.count) * pow(variance, 3.0))
        
        result = _a * (sqrt(Double(data.count * (data.count - 1))) / Double(data.count - 2))
        
        return result
    }
    
    public func Kurtosis() -> Double {
        var result: Double
        var sum: Double
        var arithMeam: Double
        var variance: Double
        var _e: Double
        
        arithMeam = arithmeticMean();
        variance = pow(_variance(), 1.0 / 2.0);
        
        sum = 0
        for item in data {
            sum += pow((item[0] - arithMeam), 4.0)
        }
        
        _e = sum / (Double(data.count) * pow(variance, 4.0))
        
        result = ((pow(Double(data.count), 2.0) - 1) / Double((data.count - 2) * (data.count - 3))) * ((_e - 3) + (6 / Double(data.count + 1)))
        
        return result
    }
    
    
    public static func getDisp(dH: (Double, Double), dX: (Double, Double), cov: Double) -> Double {
        var result = 0.0
        result = pow(dH.0, 2) * dX.0 + pow(dH.1, 2) * dX.1 + 2 * dH.0 * dH.1 * cov
        return result
    }
    
    public func CalculateQuantitativeCharacteristicsWithoutSort(alpha: Double, ch: Character) -> QuantitativeCharacteristics {
        var result = QuantitativeCharacteristics()
        var sum_arMean, sum_varianse, sum_varianse2, sum_skewness, sum_kurtosis: Double
        var _v, _a, _e: Double
        var quantil: Double
        
        
        sum_arMean = sum_varianse = sum_varianse2 = sum_skewness = sum_kurtosis = 0.0
        
        /// VALUES \\\
        for item in data {
            if (ch == "y") {
                sum_arMean += item[1]
            } else {
                sum_arMean += item[0]
            }
        }
        result.ArithmeticMean.Value = sum_arMean / data.Count
        
        
        
        for item in data {
            if (ch == "y") {
                sum_varianse += pow((item[1] - result.ArithmeticMean.Value), 2)
                sum_varianse2 += pow(item[1], 2) - pow(result.ArithmeticMean.Value, 2)
                sum_skewness += pow((item[1] - result.ArithmeticMean.Value), 3)
                sum_kurtosis += pow((item[1] - result.ArithmeticMean.Value), 4)
            } else {
                sum_varianse += pow((item[0] - result.ArithmeticMean.Value), 2)
                sum_varianse2 += pow(item[0], 2) - pow(result.ArithmeticMean.Value, 2)
                sum_skewness += pow((item[0] - result.ArithmeticMean.Value), 3)
                sum_kurtosis += pow((item[0] - result.ArithmeticMean.Value), 4)
            }
        }
        
        _v = sum_varianse2 / Double(data.count)
        _a = sum_skewness / (Double(data.count) * pow(_v, 3.0 / 2.0))
        _e = sum_kurtosis / (Double(data.count) * pow(_v, 2))
        result.Variance.Value = sum_varianse / (data.Count - 1)
        result.Skewness.Value = _a * (sqrt(data.Count * (data.Count - 1)) / (data.Count - 2))
        result.Kurtosis.Value = ((pow(data.Count, 2.0) - 1) / ((data.Count - 2) * (data.Count - 3))) * ((_e - 3) + (6 / (data.Count + 1)))
        result.Kurtosis.Value = 1 / sqrt(abs(result.Kurtosis.Value))
        
        quantil = Quantil.StudentQuantil(p: (1.0 - (alpha / 2)), v: (Double(data.count - 1)))
        
        
        
        /// Deviations \\\
        result.ArithmeticMean.StandartDeviation = sqrt(result.variance.value / Double(data.count))
        result.Variance.StandartDeviation = sqrt(result.Variance.Value / (2.0 * Double(data.count)))
        result.Skewness.StandartDeviation = sqrt((6.0 * (Double(data.count) - 2.0)) / ((Double(data.count) + 1.0) * (Double(data.count) + 3.0)))
        result.Kurtosis.StandartDeviation = sqrt(((24.0 * (Double(data.count)) * (Double(data.count) - 2.0) * (Double(data.count) - 3.0)) /
            ((Double(data.count) + 1.0) * (Double(data.count) + 1.0) * (Double(data.count) + 3.0) * (Double(data.count) + 5.0))))
        
        
        /// Intervals \\\
        
        
        result.ArithmeticMean.ConfidenceInterval.Min = result.ArithmeticMean.Value - (quantil * result.ArithmeticMean.StandartDeviation)
        result.ArithmeticMean.ConfidenceInterval.Max = result.ArithmeticMean.Value + (quantil * result.ArithmeticMean.StandartDeviation)
        
        result.Variance.ConfidenceInterval.Min = sqrt(result.Variance.Value) - (quantil * result.Variance.StandartDeviation)
        result.Variance.ConfidenceInterval.Max = sqrt(result.Variance.Value) + (quantil * result.Variance.StandartDeviation)
        
        result.Skewness.ConfidenceInterval.Min = result.Skewness.Value - (quantil * result.Skewness.StandartDeviation)
        result.Skewness.ConfidenceInterval.Max = result.Skewness.Value + (quantil * result.Skewness.StandartDeviation)
        
        result.Kurtosis.ConfidenceInterval.Min = result.Kurtosis.Value - (quantil * result.Kurtosis.StandartDeviation)
        result.Kurtosis.ConfidenceInterval.Max = result.Kurtosis.Value + (quantil * result.Kurtosis.StandartDeviation)
        
        
        
        
        return result
    }
}
