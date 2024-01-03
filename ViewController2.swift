//
//  ViewController2.swift
//  ArtBook
//
//  Created by Mehmet Emin Fırıncı on 26.12.2023.
//

import UIKit
import CoreData
class ViewController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var artist: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var buton: UIButton!
    
    var chosenPaint=""
    var chosenId:UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPaint != ""{
            buton.isHidden=true
            let appDelegate=UIApplication.shared.delegate as! AppDelegate
            let context=appDelegate.persistentContainer.viewContext
            let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idstring=chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idstring!)
            fetchRequest.returnsObjectsAsFaults=false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count>0{
                    for result in results as! [NSManagedObject]{
                        if let name=result.value(forKey: "name") as? String{
                            self.name.text=name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            self.artist.text=artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            self.year.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            self.image.image=image
                        }
                    }
                }
            }
            catch{
                print("error")
            }
        }else{
            buton.isHidden=false
            buton.isEnabled=false
        }
        image.isUserInteractionEnabled=true
        let tiklama = UITapGestureRecognizer(target: self, action: #selector(tikla))
        image.addGestureRecognizer(tiklama)
        let gestureReco = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureReco)
        
    }
    // picker ile galeriye ulaşmak
    @objc func tikla(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing=true // editleme işlemi
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        buton.isEnabled=true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context) // Art book da yazan paintings
        
        newPainting.setValue(name.text, forKey: "name")
        newPainting.setValue(artist.text, forKey: "artist")
        if let year = Int(year.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = image.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("saved")
        }catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true) // save tıkladığımda önce ki sayfaya dönüyor
    }
    

}
