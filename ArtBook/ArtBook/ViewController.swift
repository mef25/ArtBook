//
//  ViewController.swift
//  ArtBook
//
//  Created by Mehmet Emin Fırıncı on 26.12.2023.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var nameArray=[String]()
    var idArray=[UUID]()
    var selectedPaint=""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        tableView.dataSource=self
        tableView.delegate=self
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults=false
        do{
            let results = try context.fetch(fetchRequest)
            if results.count>0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let id=result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                    }
                }
            }catch{
                print("error")
            }
        
    }
    @objc func addButton(){
        selectedPaint = ""
        performSegue(withIdentifier: "pencere2", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration=content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPaint = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "pencere2", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="pencere2"{
            let destination=segue.destination as! ViewController2
            destination.chosenPaint=selectedPaint
            destination.chosenId=selectedId
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idstring=idArray[indexPath.row].uuidString
            fetchRequest.predicate=NSPredicate(format: "id = %@", idstring)
            fetchRequest.returnsObjectsAsFaults=false
            
            do{
                let results = try context!.fetch(fetchRequest)
                if results.count>0{
                    for result in results as! [NSManagedObject]{
                        if let id=result.value(forKey: "id") as? UUID{
                            if id==idArray[indexPath.row]{
                                context!.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context?.save()
                                }
                                catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }

}

