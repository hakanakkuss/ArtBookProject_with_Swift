

import UIKit
import CoreData

class toDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
   

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            }catch{
                print("error")
            }
             
            
            
            fetchRequest.returnsObjectsAsFaults = false
             
             
            
        }else{
            
                       saveButton.isHidden = false
                       saveButton.isEnabled = false
                       nameText.text = ""
                       artistText.text = ""
                       yearText.text = ""
        }
        

        // gestureRecognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        imageView.isUserInteractionEnabled = true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info [.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)  // açtığımız picker ı kapatmak için
      
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true  //fotoğraf üzerinde edit yapmaya yarar
        picker.sourceType = .photoLibrary  //fotoğrafın nereden seçileceğini belirtir
        picker.delegate = self  //picker ın fonksiyonlarını kullanabilmemiz için delegate etmemiz lazım
        present(picker, animated: true, completion: nil) //uyarı mesajları için kullanıyoruz
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(false)
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        
        do{
            try context.save()
            print("success")
        }
        catch{
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
   
    

}
