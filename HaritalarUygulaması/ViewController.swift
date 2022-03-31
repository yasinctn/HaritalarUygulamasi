//
//  ViewController2.swift
//  HaritalarUygulaması
//
//  Created by Yasin Cetin on 24.02.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenKonumIsim = ""
    var secilenKonumID : UUID?
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(ekleButton))
    
        verileriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    
    @objc func verileriAl(){
        
        isimDizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                
                for sonuc in sonuclar as! [NSManagedObject]{
                    
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                    tableView.reloadData()
                }
            }
            
        }catch{
            print("hata")
        }
    }
    
    
    
    
    
    
    @objc func ekleButton() {
        secilenKonumIsim = ""
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//************** TableView text değiştirme yeni güncellemeyle böyle yapılacak ************
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = isimDizisi[indexPath.row]
        content.textProperties.color = .purple
        cell.contentConfiguration = content
        return cell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenKonumIsim = isimDizisi[indexPath.row]
        secilenKonumID = idDizisi[indexPath.row]
        
        performSegue(withIdentifier:"toMapVC" , sender: nil )
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"{
            let destinationVC = segue.destination as! MapViewController
            destinationVC.secilenIsim = secilenKonumIsim
            destinationVC.secilenID = secilenKonumID
            
            
        }
    }
    
    
    
    
    
    
    //silme
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
              
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
            let uuıdString = idDizisi[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuıdString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0{
                    
                    for sonuc in sonuclar as! [NSManagedObject]{
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                    
                                }catch{
                                    print("hata")
                                }
                                
                                break
                            }
                        }
                    }
                }
                
            }catch{
                print("hata var")
            }
      
        }
    }
    
    
    
    
}
