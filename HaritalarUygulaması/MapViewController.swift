//
//  ViewController.swift
//  HaritalarUygulaması
//
//  Created by Yasin Cetin on 24.02.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData 

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()//sınıfı çağırdık
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    var secilenIsim = ""
    var secilenID : UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationlongitude = Double()
    
    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var konumTF: UITextField!
    @IBOutlet weak var detayTF: UITextField!
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //doğruluk seçimi
        locationManager.requestWhenInUseAuthorization()//izin alma
        locationManager.startUpdatingLocation()//konumu güncellemeye başla
        
        if secilenIsim == ""{
        let gestureRecegnizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecegnizer.minimumPressDuration = 1
            mapView.addGestureRecognizer(gestureRecegnizer)}

        kaydetButton.isEnabled = false
        kaydetButton.isHidden = true
        
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer2)
        
        if secilenIsim != "" {
            //veri çekilecek
            if let UUIDstring = secilenID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Konum")
                //filtreleme işlemi (işaretin anlamaı id si birazdan yazacağım argümana eşit olanları getir demek)
                fetchRequest.predicate = NSPredicate(format: "id = %@", UUIDstring)
                
                fetchRequest.returnsObjectsAsFaults = false
                
                
                do{
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0{
                        
                        for sonuc in sonuclar as! [NSManagedObject]{
                          
                            if let konum = sonuc.value(forKey: "isim") as? String{
                                annotationTitle = konum
                            
                            
                                if let detay = sonuc.value(forKey: "detay")as? String{
                                    annotationSubtitle = detay
                                
                                    if let latitude = sonuc.value(forKey: "latitude")as? Double{
                                        annotationLatitude = latitude
                                    
                                        if let longitude = sonuc.value(forKey: "longitude")as? Double{
                                            annotationlongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationlongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            konumTF.text = annotationTitle
                                            detayTF.text = annotationSubtitle
                                            locationManager.stopUpdatingLocation()
                                            let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                
                }catch{
                    print("hata")
                }
            }
        }else{
            //veri girecek
        }
        }
    
    @objc func klavyeKapat () {
        view.endEditing(true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "annotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil{
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId) //MKpinAnnotationViev yerine bu kullanılacak
            pinView?.canShowCallout = true
            pinView?.tintColor = .purple
            
            let button = UIButton(type: UIButton.ButtonType.infoDark)
            pinView?.rightCalloutAccessoryView = button
            
            
            
        }else {
            pinView?.annotation = annotation
        }
    
        return pinView
    }
    
   
    
    ////info butonuna tıklanınca algılama vs. fonksiyonu
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != ""{
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationlongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkDizisi, Hata) in
                if let placemarks = placemarkDizisi {
                    if placemarks.count > 0 {
                        
                        
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    @objc func konumSec(gestureRecognizer:UILongPressGestureRecognizer){
        // jest algılayıcının durumu (çalışmaya başlarsa olacaklar)
        if gestureRecognizer.state == .began{
            kaydetButton.isHidden = false
            kaydetButton.isEnabled = true
            let dokunulanNokta = gestureRecognizer.location(in:mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            //işaretleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = konumTF.text
            annotation.subtitle = detayTF.text
            mapView.addAnnotation(annotation)

        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        if secilenIsim == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        
        if konumTF.text == ""{
            uyariMesaji(titleGirdi: "Konum İsmi Girilmedi", cevapGirdi: "Tamam")
        }
        else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let yeniKonum = NSEntityDescription.insertNewObject(forEntityName: "Konum", into: context)
            yeniKonum.setValue(konumTF.text, forKey: "isim")
            yeniKonum.setValue(detayTF.text, forKey: "detay")
            yeniKonum.setValue(secilenLatitude, forKey: "latitude")
            yeniKonum.setValue(secilenLongitude, forKey: "longitude")
            yeniKonum.setValue(UUID(), forKey: "id")
            
            
            do{
                try context.save()
                print("kayıt başarılı")
            }catch{
                print("hata var")
            }
            
                hataMesaji(titleGirdi: "Kayıt Başarılı", cevapGirdi: "Devam")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
            
            
            
        }
}
    
    func hataMesaji (titleGirdi:String, cevapGirdi: String){
        let allertMessage = UIAlertController(title: titleGirdi, message: nil, preferredStyle: UIAlertController.Style.alert)
        let devamTiklandi = UIAlertAction(title: cevapGirdi, style: UIAlertAction.Style.default){
            (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)  // devam tıklanınca bir önceki viewController a geri döner
        }
        
        allertMessage.addAction(devamTiklandi)
        self.present(allertMessage, animated: true, completion: nil)
        
    }
    
    func uyariMesaji (titleGirdi:String, cevapGirdi: String){
        let allertMessage = UIAlertController(title: titleGirdi, message: nil, preferredStyle: UIAlertController.Style.alert)
        let devamTiklandi = UIAlertAction(title: cevapGirdi, style: UIAlertAction.Style.default){
            (UIAlertAction) in
        }
    }

    
    
    
    
    
}
