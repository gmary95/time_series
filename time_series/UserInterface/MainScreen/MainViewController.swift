//
//  ViewController.swift
//  time_series
//
//  Created by Mary Gerina on 10/25/18.
//  Copyright © 2018 Mary Gerina. All rights reserved.
//

import Cocoa
import CoreData

class MainViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var labelSelectedMenuItem: NSTextField!
    
    let path = "/Users/gmary/Desktop/"
    var filename_field: String!
    
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
                arrayOfDoubleValue.append(Double(elem) ?? 0.0)
            }
            let isWriteToDB = writeToCoreData(elements: arrayOfDoubleValue)
            if isWriteToDB {
                timeSeriesTabel.reloadData()
            }
        } catch {
            let answer = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    func writeToCoreData(elements: Array<Double>) -> Bool {
        self.deleteAllRecords()
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Element", in: context)
        var isWrite = false
        
        elements.forEach {
            let newElement = NSManagedObject(entity: entity!, insertInto: context)
            newElement.setValue($0, forKey: "value")
            
            do {
                try context.save()
                isWrite = true
            } catch {
                print("Failed saving")
            }
        }
        return isWrite
    }
    
    func deleteAllRecords() {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Element")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func getAllRecords() -> [Element] {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let employeesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Element")
        
        do {
            let fetchedElements = try context.fetch(employeesFetch)
            return fetchedElements as! [Element]
        } catch {
            print ("Failed to fetch employees: \(error)")
            return []
        }
    }
}

extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let numberOfRows:Int = getAllRecords().count
        return numberOfRows
    }
    
}

extension MainViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let elements = getAllRecords()

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
