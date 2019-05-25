//
//  TableViewController.swift
//  CoreDataDemo
//
//  Created by Давид on 14/04/2019.
//  Copyright © 2019 Давид. All rights reserved.
//

import CoreData
import UIKit

class TableViewController: UITableViewController {

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate // сначала добираемся до файла appdelegate
    
    //var toDoItems: [String] = []
    var toDoItems: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // загрузка сохраненных данных из CoreData
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // сначала добираемся до файла appdelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest() // обращаемся к базе данных и получаем сущности таск
        
        do {
            toDoItems = try context.fetch(fetchRequest) // полученные результаты сохраняем в массив
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoItems.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = toDoItems[indexPath.row]
        cell.textLabel?.text = task.taskToDo
        
        return cell
    }
    
    // редактирование
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemForEdit = toDoItems[indexPath.row]
        
        let alert = UIAlertController(
            title: "Изменить задачу",
            message: "Заполните поле",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(
            title: "Сохранить",
            style: .default) { (action) in
                guard alert.textFields?.first?.text?.isEmpty == false else {
                    print("The text field is empty")
                    return
                }
                let newText = alert.textFields?.first?.text
                self.save(itemForEdit, newName: newText!)
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .destructive,
            handler: nil
        )
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // удаление
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
         let itemToDelet = toDoItems[indexPath.row]
        
        let manageContext = appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete {
            do {
                manageContext.delete(itemToDelet)
                try manageContext.save()
            } catch {
                print("Error: \(error), description \(error.localizedDescription)")
            }
            toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
    }

    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Add Task",
            message: "add new task",
            preferredStyle: .alert)
        
        let ok = UIAlertAction(
            title: "OK",
            style: .default) { (action) in
                let textField = alert.textFields?.first
                self.saveTask(taskToDo: (textField?.text)!)
                //self.toDoItems.insert((textField?.text)!, at: 0)
                self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .default,
            handler: nil)
        
        alert.addTextField { (textField) in
            
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    // сохранение объектов
    func saveTask(taskToDo: String) {

        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) // обозначаем для какой сущности создаем объект
        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! Task   // создание объекта на основе сущности и контекста
        taskObject.taskToDo = taskToDo
        
        do {
            try context.save()
            toDoItems.append(taskObject)
            print("Saved!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // сохранение Отредактированных объектов в базе и массиве
    func save(_ taskToDo: Task, newName: String) {
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
            taskToDo.taskToDo = newName
            print("Saved!")
        } catch {
            print(error.localizedDescription)
        }
    }
}
