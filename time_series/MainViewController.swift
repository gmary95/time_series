//
//  ViewController.swift
//  time_series
//
//  Created by Mary Gerina on 10/25/18.
//  Copyright © 2018 Mary Gerina. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var labelSelectedMenuItem: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func openFile(_ sender: NSMenuItem) {
            print("ViewController:actionMenuItemSelected")
            labelSelectedMenuItem.stringValue = "Selected menu item: " + sender.title
        timeSeriesTabel.backgroundColor = .blue
    }

}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let DateCell = "DateCellID"
        static let SizeCell = "SizeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        var image: NSImage?
//        var text: String = ""
//        var cellIdentifier: String = ""
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .long
//
//        // 1
//        guard let item = directoryItems?[row] else {
//            return nil
//        }
//
//        // 2
//        if tableColumn == tableView.tableColumns[0] {
//            image = item.icon
//            text = item.name
//            cellIdentifier = CellIdentifiers.NameCell
//        } else if tableColumn == tableView.tableColumns[1] {
//            text = dateFormatter.string(from: item.date)
//            cellIdentifier = CellIdentifiers.DateCell
//        } else if tableColumn == tableView.tableColumns[2] {
//            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
//            cellIdentifier = CellIdentifiers.SizeCell
//        }
//
//        // 3
//        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
//            cell.textField?.stringValue = text
//            cell.imageView?.image = image ?? nil
//            return cell
//        }
        return nil
    }
    
}
