 public class Data {
    
    public var data: [Double]{
        get{
            return self.data
        }
        set {
            data = newValue
        }
    }
    public var count: Int {
        get{
            return self.count
        }
        set {
            count = newValue
        }
    }
    
    
    init() {
        self.count = 1
        self.data = [Double](repeating: 0.0, count: count)
    }
    
    init(length: Int) {
        self.count = length
        self.data = [Double](repeating: 0.0, count: length)
    }
    
    init(data: [Double]) {
        self.count = data.count
        self.data = [Double](repeating: 0.0, count: count)
        
        for i in 0 ..< data.count {
            self.data[i] = data[i]
        }
    }
    
    public typealias Index = Int
    
    public var startIndex: Index {
        return data.startIndex
    }
    
    public var endIndex: Index {
        return data.endIndex
    }
    
    subscript(index: Index) -> Double {
    get
    {
        if ((index >= 0) && (index < self.count)) {
            return (self.data[index])
        } else {
            print("Ivalid index!")
        }
        return 0.0
    }
        set
        {
            if ((index >= 0) && (index < self.count)) {
                data[index] = newValue
                
            } else {
                print("Ivalid index!")
            }
        }
    }
    
    public func index(after i: Index) -> Index {
        return data.index(after: i)
    }
    
     public func remove(item: Double) {
        for i in 0 ..< data.count {
            if data[i] == item {
                data.remove(at: i)
            }
        }
    }
 }
