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
    
    let path = "/Users/gmary/Desktop/"
    var filename_field: String!
    var dao: ElementsDAO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeSeriesRepresentationChart.noDataTextColor = .white
        
        self.dao = ElementsDAO()
    }
    
    @IBAction func openFile(_ sender: NSMenuItem) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["dat", "txt", "dbf"];
        
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

    func representChart(timeSeries: Array<Double>){
        // Do any additional setup after loading the view.
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        self.timeSeriesRepresentationChart.data = data
        
        self.timeSeriesRepresentationChart.gridBackgroundColor = .red
        self.timeSeriesRepresentationChart.legend.textColor = .white
        self.timeSeriesRepresentationChart.xAxis.labelTextColor = .white
        self.timeSeriesRepresentationChart.leftAxis.labelTextColor = .white
        self.timeSeriesRepresentationChart.rightAxis.labelTextColor = .white
    }
    
    func openAndRead(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            let elements = content.components(separatedBy: "\n")
            var arrayOfDoubleValue = Array<Double>()
            elements.forEach {
                var elem = $0
                if elem.last == "\r" {
                    _ = elem.removeLast()
                }
                if let value = Double(elem) {
                    arrayOfDoubleValue.append(value)
                }
            }
            let isWriteToDB = dao.writeToCoreData(elements: arrayOfDoubleValue)
            if isWriteToDB {
                representChart(timeSeries: arrayOfDoubleValue)
                timeSeriesTabel.reloadData()
            }
        } catch {
            let answer = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    @IBAction func exit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
   
}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let numberOfRows:Int = dao.getAllRecords().count
        return numberOfRows
    }
    
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let elements = dao.getAllRecords()

        var text: String = ""
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            text = "\(row)"
            cellIdentifier = CellIdentifiers.IndexCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(elements[row].value)"
            cellIdentifier = CellIdentifiers.ValueCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
