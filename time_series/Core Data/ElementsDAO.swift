import CoreData
import Cocoa

class ElementsDAO {
    var appDelegate: AppDelegate
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    
    init() {
        appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        context = appDelegate.persistentContainer.viewContext
        
        entity = NSEntityDescription.entity(forEntityName: "Element", in: context)
    }
    
    func writeToCoreData(elements: Array<Double>) -> Bool {
        self.deleteAllRecords()
        
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
