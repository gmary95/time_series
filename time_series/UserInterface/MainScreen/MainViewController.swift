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
    @IBOutlet weak var testRegresionTabel: NSScrollView!
    
    let path = "/Users/gmary/Desktop/"
    let alph = 0.05
    
    var filename_field: String!
    var dao: ElementsDAO!
    var dictionaryOfTimeSeries = Dictionary<String, Double>()
    var dictionaryOfRуgresion = Dictionary<String, Double>()
    var dictionaryOfLeftovers = Dictionary<String, Double>()
    var spirTest:SpearmanTestCalculator?
    var linearRegresion: LinearRegresion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSeriesRepresentationChart.noDataTextColor = .white
        
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
                openAndRead(filePath: result!)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func representChart(timeSeries: Array<Double>, regresion: Array<Double>){
        // Do any additional setup after loading the view.
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        //        let regresionSet = regresion.enumerated().map { (arg) -> ChartDataEntry in
        //
        //            let (x, y) = arg
        //            return ChartDataEntry(x: Double(x), y: y) }
        //
        //        let dataSetRegresion = LineChartDataSet(values: regresionSet, label: "Linear regresion")
        //        dataSetRegresion.colors = [NSUIColor.red]
        //        dataSetRegresion.valueColors = [NSUIColor.clear]
        //        dataSetRegresion.drawCirclesEnabled = false
        //        data.addDataSet(dataSetRegresion)
        
        self.timeSeriesRepresentationChart.data = data
        
        self.timeSeriesRepresentationChart.gridBackgroundColor = .red
        self.timeSeriesRepresentationChart.legend.textColor = .white
        self.timeSeriesRepresentationChart.xAxis.labelTextColor = .white
        self.timeSeriesRepresentationChart.leftAxis.labelTextColor = .white
        self.timeSeriesRepresentationChart.rightAxis.labelTextColor = .white
    }
    
    func representLefovers(leftover: Array<Double>){
        // Do any additional setup after loading the view.
        let leftoverSeries = leftover.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: pow(y, 2.0)) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: leftoverSeries, label: "Leftover")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        self.linearLeftoversChart.data = data
        
        self.linearLeftoversChart.gridBackgroundColor = .red
        self.linearLeftoversChart.legend.textColor = .white
        self.linearLeftoversChart.xAxis.labelTextColor = .white
        self.linearLeftoversChart.leftAxis.labelTextColor = .white
        self.linearLeftoversChart.rightAxis.labelTextColor = .white
    }
    
    func dictionaryToArray(dictionary: Dictionary<String, Double>) -> Array<Double> {
        let array = Array(dictionary.values)
        return array
    }
    
    func openAndRead(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            var elements = content.components(separatedBy: "\n")
            var i = 0
            elements.forEach {
                i += 1
                var elem = $0
                if elem.last == "\r" {
                    _ = elem.removeLast()
                }
                if let value = Double(elem) {
                    dictionaryOfTimeSeries["\(i)"] = value
                }
                //                var elem = $0//.components(separatedBy: ",")
                ////                elements.remove(at: 0)
                
                //                if let value = Double(elem/*.last ?? ""), let key = elem.first*/)  {
                //                    dictionaryOfTimeSeries["\(i)"] = value
                //                }
            }
            let array = dictionaryToArray(dictionary: dictionaryOfTimeSeries)
            timeSeriesTabel.reloadData()
            
            let selection = Selection(order: 1, capacity: 0)
            for item in array {
                selection.append(item: item)
            }
            spirTest = SpearmanTestCalculator(selection: selection)
            spearmanTestTable.reloadData()
            
            linearRegresion = LinearRegresion(selection: selection)
            linearRegresion?.initAllParam()
            dictionaryOfRуgresion = [:]
            i = 0
            dictionaryOfTimeSeries.forEach {
                i += 1
                dictionaryOfRуgresion[$0.key] = linearRegresion!.a! + linearRegresion!.b! * Double(i)
            }
            linearParameterTable.reloadData()
            let regresion = dictionaryToArray(dictionary: dictionaryOfRуgresion)
            
            representChart(timeSeries: array, regresion: regresion)
            
            dictionaryOfLeftovers = [:]
            dictionaryOfTimeSeries.forEach {
                dictionaryOfLeftovers[$0.key] = $0.value - dictionaryOfRуgresion[$0.key]!
            }
            let leftovers = dictionaryToArray(dictionary: dictionaryOfLeftovers)
            representLefovers(leftover: leftovers)
        } catch {
            _ = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    @IBAction func exit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == timeSeriesTabel {
            let numberOfRows:Int = dictionaryOfTimeSeries.count
            return numberOfRows
        }
        if tableView == spearmanTestTable {
            return 1
        }
        if tableView == linearParameterTable {
            return 2
        }
        return 0
    }
    
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersSelectionTable {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
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
        if tableView == spearmanTestTable {
            return loadSpearmanTest(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == linearParameterTable {
            return loadParameter(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    func loadSpearmanTest(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            if let test = spirTest?.CalcRC() {
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
                text = (spirTest?.makeDecision(alph: alph)) ?? ""
            }
            cellIdentifier = CellIdentifiersSpearmanTable.ResultCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func loadSelection(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        let elements = dictionaryOfTimeSeries
        
        if elements.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(Array(elements.keys)[row])"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(Array(elements.values)[row])"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
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
}
