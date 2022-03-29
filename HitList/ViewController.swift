//
//  ViewController.swift
//  HitList
//
//  Created by Eclectics on 28/03/2022.
//

import UIKit
import CoreData

/***
 Core Data provides on-disk persistence, which means your data will be accessible even after terminating your app or shutting down your device. This is different from in-memory persistence, which will only save your data as long as your app is in memory, either in the foreground or in the background.
 Xcode comes with a powerful Data Model editor, which you can use to create your managed object model.
 A managed object model is made up of entities, attributes and relationships
 An entity is a class definition in Core Data.
 An attribute is a piece of information attached to an entity.
 A relationship is a link between multiple entities.
 An NSManagedObject is a run-time representation of a Core Data entity. You can read and write to its attributes using Key-Value Coding.
 You need an NSManagedObjectContext to save() or fetch(_:) data to and from Core Data.
 */

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var names: [String] = []
    
    //NSManagedObject represents a single object stored in Core Data; you must use it to create, edit, save and delete from your Core Data persistent store.
    var people: [NSManagedObject] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //This will set a title on the navigation bar and register the UITableViewCell class with the table view.
        
        //register(_:forCellReuseIdentifier:) guarantees your table view will return a cell of the correct type when the Cell reuseIdentifier is provided to the dequeue method.
        title = "The list"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      //1 Before you can do anything with Core Data, you need a managed object context. Fetching is no different! Like before, you pull up the application delegate and grab a reference to its persistent container to get your hands on its NSManagedObjectContext.
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      //2 NSFetchRequest is the class responsible for fetching from Core Data.
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Person")
      
      //3 You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.
      do {
        people = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }


    
    // Implement the addName IBAction
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name",
                                        message: "Add a new name",
                                        preferredStyle: .alert)
          
         /** let saveAction = UIAlertAction(title: "Save",
                                         style: .default) {
            [unowned self] action in
                                          
            guard let textField = alert.textFields?.first,
              let nameToSave = textField.text else {
                return
            }
            
            self.names.append(nameToSave)
            self.tableView.reloadData()
          }**/
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
          [unowned self] action in
          
          guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
              return
          }
          
          self.save(name: nameToSave)
          self.tableView.reloadData()
        }

          
          let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .cancel)
          
          alert.addTextField()
          
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
          
          present(alert, animated: true)
    }
    
    func save(name: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1  NSManagedObjectContext= a managed object context as an in-memory “scratchpad” for working with managed objects.
//        Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; once you’re happy, you “commit” the changes in your managed object context to save it to disk.
        
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2 You create a new managed object and insert it into the managed object context.
      let entity =
        NSEntityDescription.entity(forEntityName: "Person",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3 With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model, otherwise, your app will crash at runtime.

      person.setValue(name, forKeyPath: "name")
      
      // 4 You commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
      do {
        try managedContext.save()
        people.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
       
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let person = people[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
                     
//As it turns out, NSManagedObject doesn’t know about the name attribute you defined in your Data Model, so there’s no way of accessing it directly with a property. The only way Core Data provides to read the value is key-value coding, commonly referred to as KVC.
                     
//KVC is a mechanism in Foundation for accessing an object’s properties indirectly using strings. In this case, KVC makes NSMangedObject behave somewhat like a dictionary at runtime.
    cell.textLabel?.text =
      person.value(forKeyPath: "name") as? String
    return cell
  }
}
/**extension ViewController: UITableViewDataSource {
  
    //First you return the number of rows in the table as the number of items in your names array.
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return names.count
  }
  
    //dequeues table view cells and populates them with the corresponding string from the names array.
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
    cell.textLabel?.text = names[indexPath.row]
    return cell
  }
}**/


