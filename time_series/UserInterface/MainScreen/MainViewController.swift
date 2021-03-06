//
//  ViewController.swift
//  time_series
//
//  Created by Mary Gerina on 10/25/18.
//  Copyright © 2018 Mary Gerina. All rights reserved.
//

import Cocoa
import CoreData
import Charts

class MainViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var timeSeriesRepresentationChart: LineChartView!
    @IBOutlet weak var spearmanTestTable: NSTableView!
    @IBOutlet weak var linearParameterTable: NSTableView!
    @IBOutlet weak var linearLeftoversChart: LineChartView!
    @IBOutlet weak var testRegresionTabel: NSTableView!
    @IBOutlet weak var leftoversParametersTable: NSTableView!
    @IBOutlet weak var leftoversTable: NSTableView!
    @IBOutlet weak var autocorrTable: NSTableView!
    @IBOutlet weak var autocorrParameterTable: NSTableView!
    @IBOutlet weak var autocorrChart: LineChartView!
    
    let path = "/Users/gmary/Desktop/"
    let alph = 0.4
    
    var filename_field: String!
    var dao: ElementsDAO!
    var arrayOfTimeSeries = Array<Double>()
    var arrayOfName = Array<String>()
    var arrayOfRegresion = Array<Double>()
    var arrayOfLeftovers = Array<Double>()
    var arrayOfLeftoversRegresion = Array<Double>()
    var arrayOfNewT = Array<Double>()
    var arrayOfNewSelection = Array<Double>()
    var arrayOfNewTAuto = Array<Double>()
    var arrayOfNewSelectionAuto = Array<Double>()
    var spirTest:SpearmanTestCalculator?
    var dwTest: DarbinWatsonCalculator?
    var linearRegresion: LinearRegresion?
    var linearLefoversRegresion: LinearRegresion?
    var linearNewRegresion: LinearRegresion?
    var linearNewRegresionAuto: LinearRegresion?
    var selectionLefovers = Selection(order: 1, capacity: 0)
    var selectionLefoversPow = Selection(order: 1, capacity: 0)
    var selection = Selection(order: 1, capacity: 0)
    var newSelection = Selection(order: 1, capacity: 0)
    var newAutoSelection = Selection(order: 1, capacity: 0)
    
    var isHomoskedastic = false
    var isAutocorrelation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSeriesRepresentationChart.noDataTextColor = .white
        self.linearLeftoversChart.noDataTextColor = .white
        self.autocorrChart.noDataTextColor = .white
        
        self.dao = ElementsDAO()
    }
    
    @IBAction func openFile(_ sender: NSMenuItem) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["dat", "csv"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                filename_field = path
                arrayOfTimeSeries = []
                arrayOfName = []
                openAndRead(filePath: result!)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func representChart(timeSeries: Array<Double>, regresion: Array<Double>?, chart: LineChartView){
        // Do any additional setup after loading the view.
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        if let reg = regresion {
            let regresionSet = reg.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
            
            let dataSetRegresion = LineChartDataSet(values: regresionSet, label: "Linear regresion")
            dataSetRegresion.colors = [NSUIColor.red]
            dataSetRegresion.valueColors = [NSUIColor.clear]
            dataSetRegresion.drawCirclesEnabled = false
            data.addDataSet(dataSetRegresion)
        }
        
        chart.data = data
        
        chart.gridBackgroundColor = .red
        chart.legend.textColor = .white
        chart.xAxis.labelTextColor = .white
        chart.leftAxis.labelTextColor = .white
        chart.rightAxis.labelTextColor = .white
    }
    
    //    func representLefovers(leftover: Array<Double>){
    //        // Do any additional setup after loading the view.
    //        let leftoverSeries = leftover.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: pow(y, 2.0)) }
    //
    //        let data = LineChartData()
    //        let dataSet = LineChartDataSet(values: leftoverSeries, label: "Leftover")
    //        dataSet.colors = [NSUIColor.yellow]
    //        dataSet.valueColors = [NSUIColor.white]
    //        data.addDataSet(dataSet)
    //
    //        self.linearLeftoversChart.data = data
    //
    //        self.linearLeftoversChart.gridBackgroundColor = .red
    //        self.linearLeftoversChart.legend.textColor = .white
    //        self.linearLeftoversChart.xAxis.labelTextColor = .white
    //        self.linearLeftoversChart.leftAxis.labelTextColor = .white
    //        self.linearLeftoversChart.rightAxis.labelTextColor = .white
    //    }
    
    func dictionaryToArray(dictionary: Dictionary<String, Double>) -> Array<Double> {
        let array = Array(dictionary.values)
        return array
    }
    
    func openAndRead(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            var elements = content.components(separatedBy: "\n")
//            var i = 0
            elements.remove(at: 0)
            elements.forEach {
//                i += 1
//                var elem = $0
//                if elem.last == "\r" {
//                    _ = elem.removeLast()
//                }
//                if let value = Double(elem) {
//                    arrayOfTimeSeries.append(value)
//                    arrayOfName.append("\(i)")
//                }
                let elem = $0.components(separatedBy: ",")
                
                if let value = Double(elem.last ?? ""), let key = elem.first  {
                    arrayOfTimeSeries.append(value)
                    arrayOfName.append("\(key)")
                }
            }
            
            selection = Selection(order: 1, capacity: 0)
            for item in arrayOfTimeSeries {
                selection.append(item: item)
            }
            
            linearRegresion = LinearRegresion(selection: selection)
            linearRegresion?.initAllParam()
            arrayOfRegresion = []
            var elem = 0.0
            for i in 0 ..< arrayOfTimeSeries.count {
                elem = linearRegresion!.a! + (linearRegresion!.b! * Double(i + 1))
                arrayOfRegresion.append(elem)
            }
            linearParameterTable.reloadData()
            
            representChart(timeSeries: arrayOfTimeSeries, regresion: arrayOfRegresion, chart: timeSeriesRepresentationChart)
            timeSeriesTabel.reloadData()
            
            calcLeftovers()
            
            calcHaracteristics()
            let (_, isHomo) = (spirTest?.makeDecision(alph: alph))!
            isHomoskedastic = isHomo
            
            let (_, isAuto) = (dwTest?.makeDecision())!
            isAutocorrelation = isAuto
            spearmanTestTable.reloadData()
            
            if !isHomoskedastic {
                removeHeteroscedastic()
            } else {
                arrayOfNewSelection = []
                arrayOfNewT = []
            }
            leftoversTable.reloadData()
            testRegresionTabel.reloadData()
            
            representChart(timeSeries: selectionLefovers.data, regresion: nil, chart: autocorrChart)
            
            if isAutocorrelation {
                deleteAutocorr()
            } else {
                arrayOfNewSelectionAuto = []
                arrayOfNewTAuto = []
            }
            autocorrTable.reloadData()
            autocorrParameterTable.reloadData()
        } catch {
            _ = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    @IBAction func exit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func calcHaracteristics() {
        spirTest = SpearmanTestCalculator(selection: selection, leftovers: arrayOfLeftovers)
        selectionLefovers = Selection(order: 1, capacity: 0)
        for item in arrayOfLeftovers {
            selectionLefovers.append(item: item)
        }
        dwTest = DarbinWatsonCalculator(selection: selectionLefovers)
    }
    
    func calcLeftovers() {
        arrayOfLeftovers = []
        var elem = 0.0
        for i in 0 ..< arrayOfTimeSeries.count {
            elem = abs(arrayOfTimeSeries[i] - arrayOfRegresion[i])
            arrayOfLeftovers.append(elem)
        }
        
        selectionLefoversPow = Selection(order: 1, capacity: 0)
        for item in arrayOfLeftovers {
            selectionLefoversPow.append(item: item * item)
        }
        
        linearLefoversRegresion = LinearRegresion(selection: selectionLefoversPow)
        linearLefoversRegresion?.initAllParam()
        arrayOfLeftoversRegresion = []
        elem = 0.0
        for i in 0 ..< arrayOfLeftovers.count {
            elem = linearLefoversRegresion!.a! + (linearLefoversRegresion!.b! * Double(i + 1))
            arrayOfLeftoversRegresion.append(elem)
        }
        leftoversParametersTable.reloadData()
        representChart(timeSeries: selectionLefoversPow.data, regresion: arrayOfLeftoversRegresion, chart: linearLeftoversChart)
    }
    
    func removeHeteroscedastic() {
        arrayOfNewSelection = []
        var elem = 0.0
        for i in 0 ..< arrayOfTimeSeries.count {
            elem = arrayOfTimeSeries[i] / arrayOfLeftoversRegresion[i]
            arrayOfNewSelection.append(elem)
        }
        
        arrayOfNewT = []
        elem = 0.0
        for i in 0 ..< arrayOfTimeSeries.count {
            elem = Double(i + 1) / arrayOfLeftoversRegresion[i]
            arrayOfNewT.append(elem)
        }
        
        newSelection = Selection(order: 1, capacity: 0)
        for item in arrayOfNewSelection {
            newSelection.append(item: item)
        }
        
        linearNewRegresion = LinearRegresion(selection: newSelection)
        linearNewRegresion?.initAllParam()
    }
    
    func deleteAutocorr() {
        let a = AutoCorrManager(dw: (dwTest?.CalcDW())!).calculateAlph()
        arrayOfNewSelectionAuto = []
        arrayOfNewSelectionAuto.append(arrayOfTimeSeries[0])
        var elem = 0.0
        for i in 1 ..< arrayOfTimeSeries.count {
            elem = arrayOfTimeSeries[i] - (a * arrayOfTimeSeries[i - 1])
            arrayOfNewSelectionAuto.append(elem)
        }
        
        arrayOfNewTAuto = []
        arrayOfNewTAuto.append(1)
        elem = 0.0
        for i in 1 ..< arrayOfTimeSeries.count {
            elem = Double(i + 1) - (a * Double(i))
            arrayOfNewTAuto.append(elem)
        }
        
        newAutoSelection = Selection(order: 1, capacity: 0)
        for item in arrayOfNewSelectionAuto {
            newAutoSelection.append(item: item)
        }
        
        linearNewRegresionAuto = LinearRegresion(selection: newAutoSelection)
        linearNewRegresionAuto?.initAllParam()
    }
}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == timeSeriesTabel || tableView == leftoversTable || tableView == autocorrTable{
            let numberOfRows:Int = arrayOfTimeSeries.count
            return numberOfRows
        }
        if tableView == spearmanTestTable {
            return 2
        }
        if tableView == linearParameterTable || tableView == leftoversParametersTable || tableView == testRegresionTabel || tableView == autocorrParameterTable{
            return 2
        }
        return 0
    }
    
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersSelectionTable {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
        static let RegressionCell = "RegressionID"
        static let NewTCell = "NewTID"
        static let NewValueCell = "NewValueID"
    }
    
    fileprivate enum CellIdentifiersSpearmanTable {
        static let ValueCell = "ValueID"
        static let QuantilCell = "QuantilID"
        static let ResultCell = "ResultID"
    }
    
    fileprivate enum CellIdentifiersLinearTable {
        static let ValueCell = "AID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == timeSeriesTabel {
            return loadSelection(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == leftoversTable {
            return loadLeftovers(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == spearmanTestTable {
            return loadSpearmanTest(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == linearParameterTable {
            return loadParameter(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == leftoversParametersTable {
            return loadParameterLeftovers(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == testRegresionTabel {
            return loadNewParameter(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == autocorrTable {
            return loadAutocorr(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == autocorrParameterTable {
            return loadNewParameterAuto(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    func loadSpearmanTest(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if row == 0 {
            if tableColumn == tableView.tableColumns[0] {
                if let test = spirTest?.CalcS() {
                    text = "\(test.rounded(toPlaces: 6))"
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ValueCell
            } else if tableColumn == tableView.tableColumns[1] {
                if let test = spirTest {
                    let quantil = Quantil.StudentQuantil(p: alph / 2.0, v: Double(test.selection.count - 2))
                    text = "\(quantil.rounded(toPlaces: 6))"
                }
                cellIdentifier = CellIdentifiersSpearmanTable.QuantilCell
            } else if tableColumn == tableView.tableColumns[2] {
                if let test = spirTest {
                    text = (test.makeDecision(alph: alph).0) ?? ""
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ResultCell
            }
        } else {
            if tableColumn == tableView.tableColumns[0] {
                if let test = dwTest?.CalcDW() {
                    text = "\(test.rounded(toPlaces: 6))"
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ValueCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "-"
                cellIdentifier = CellIdentifiersSpearmanTable.QuantilCell
            } else if tableColumn == tableView.tableColumns[2] {
                if let test = dwTest {
                    text = (test.makeDecision().0)
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ResultCell
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func loadSelection(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfTimeSeries.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(arrayOfName[row])"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(arrayOfTimeSeries[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                text = "\(arrayOfRegresion[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.RegressionCell
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadLeftovers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfLeftovers.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(arrayOfName[row])"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(pow(arrayOfLeftovers[row], 2.0).rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                text = "\(arrayOfLeftoversRegresion[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.RegressionCell
            }
        
            if arrayOfNewSelection.count > 0 {
                if tableColumn == tableView.tableColumns[3] {
                    text = "\(arrayOfNewSelection[row].rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.NewValueCell
                } else if tableColumn == tableView.tableColumns[4] {
                    text = "\(arrayOfNewT[row].rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.NewTCell
                }
            }
                
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                    cell.textField?.stringValue = text
                    return cell
                }
            
        }
        return nil
    }
    
    func loadAutocorr(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfTimeSeries.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(arrayOfName[row])"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(arrayOfTimeSeries[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                text = "\(arrayOfRegresion[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.RegressionCell
            }
            if arrayOfNewSelectionAuto.count > 0 {
                if tableColumn == tableView.tableColumns[3] {
                    text = "\(arrayOfNewSelectionAuto[row].rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.NewValueCell
                } else if tableColumn == tableView.tableColumns[4] {
                    text = "\(arrayOfNewTAuto[row].rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.NewTCell
                }
            } else {
                if tableColumn == tableView.tableColumns[3] {
                    text = ""
                    cellIdentifier = CellIdentifiersSelectionTable.NewValueCell
                } else if tableColumn == tableView.tableColumns[4] {
                    text = ""
                    cellIdentifier = CellIdentifiersSelectionTable.NewTCell
                }
            }
                
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadParameter(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        if let linear = linearRegresion {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                switch row {
                case 0:
                    text = "\(linear.a!.rounded(toPlaces: 6))"
                case 1:
                    text = "\(linear.b!.rounded(toPlaces: 6))"
                default: break
                }
                cellIdentifier = CellIdentifiersLinearTable.ValueCell
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadParameterLeftovers(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        if let linear = linearLefoversRegresion {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                switch row {
                case 0:
                    text = "\(linear.a!.rounded(toPlaces: 6))"
                case 1:
                    text = "\(linear.b!.rounded(toPlaces: 6))"
                default: break
                }
                cellIdentifier = CellIdentifiersLinearTable.ValueCell
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadNewParameter(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        if let linear = linearNewRegresion {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if arrayOfNewSelection.count > 0 {
                if tableColumn == tableView.tableColumns[0] {
                    switch row {
                    case 0:
                        text = "\(linear.a!.rounded(toPlaces: 6))"
                    case 1:
                        text = "\(linear.b!.rounded(toPlaces: 6))"
                    default: break
                    }
                    cellIdentifier = CellIdentifiersLinearTable.ValueCell
                }
            } else {
                if tableColumn == tableView.tableColumns[0] {
                    text = ""
                    cellIdentifier = CellIdentifiersLinearTable.ValueCell
                }
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadNewParameterAuto(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        if let linear = linearNewRegresionAuto {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if arrayOfNewSelectionAuto.count > 0 {
                if tableColumn == tableView.tableColumns[0] {
                    switch row {
                    case 0:
                        text = "\(linear.a!.rounded(toPlaces: 6))"
                    case 1:
                        text = "\(linear.b!.rounded(toPlaces: 6))"
                    default: break
                    }
                    cellIdentifier = CellIdentifiersLinearTable.ValueCell
                    
                }
            } else {
                if tableColumn == tableView.tableColumns[0] {
                    text = ""
                    cellIdentifier = CellIdentifiersLinearTable.ValueCell
                }
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
}
