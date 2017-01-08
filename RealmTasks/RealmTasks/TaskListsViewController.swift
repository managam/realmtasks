//
//  TaskListsViewController.swift
//  RealmTasks
//
//  Created by Hossam Ghareeb on 10/13/15.
//  Copyright © 2015 Hossam Ghareeb. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var lists : Results<TaskList>!
    
    var isEditingMode = false
    
    var currentCreateAction:UIAlertAction!
    @IBOutlet weak var taskListsTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        readTasksAndUpdateUI()
    }
    
    func readTasksAndUpdateUI() {
        lists = uiRealm.objects(TaskList.self)
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - User Actions
    
    @IBAction func didSelectSortCriteria(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // A-Z
            self.lists = self.lists.sorted(byProperty: "name")
        } else {
            // date
            self.lists = self.lists.sorted(byProperty: "createdAt", ascending:false)
        }
        self.taskListsTableView.reloadData()
    }
    
    @IBAction func didClickOnEditButton(sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.taskListsTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(sender: UIBarButtonItem) {
        displayAlertToAddTaskList(updatedList: nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    func listNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTaskList(updatedList: TaskList!){
        var title = "New Tasks List"
        var doneTitle = "Create"
        
        if updatedList != nil{
            title = "Update Tasks List"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil{
                // Update mode
                try! uiRealm.write{
                    updatedList.name = listName!
                    self.readTasksAndUpdateUI()
                }
            } else{
                
                let newTaskList = TaskList()
                newTaskList.name = listName!
                
                try! uiRealm.write{
                    
                    uiRealm.add(newTaskList)
                    self.readTasksAndUpdateUI()
                }
            }
            
            print(listName!)
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(self.listNameFieldDidChange), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tasksViewController = segue.destination as! TasksViewController
        tasksViewController.selectedList = sender as! TaskList
    }
    
}

// MARK: - UITableViewDataSource

extension TaskListsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listsTasks = lists{
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = taskListsTableView.dequeueReusableCell(withIdentifier: "listCell")
        let list = lists[indexPath.row]
        cell?.textLabel?.text = list.name
        cell?.detailTextLabel?.text = "\(list.tasks.count) Tasks"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            //Deletion will go here
            let listToBeDeleted = self.lists[indexPath.row]
            try! uiRealm.write{
                uiRealm.delete(listToBeDeleted)
                self.readTasksAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            // Editing will go here
            let listToBeUpdated = self.lists[indexPath.row]
            self.displayAlertToAddTaskList(updatedList: listToBeUpdated)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "navigateToTasksVC", sender: self.lists[indexPath.row])
    }
}
