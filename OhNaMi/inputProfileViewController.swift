//
//  inputProfileViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 24/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit
import CoreData

class inputProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var array = Array<String>()
    
    var count: Int!

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var age: UISegmentedControl!
    //@IBOutlet weak var age_part: UISegmentedControl!
    
    @IBOutlet weak var nick: UITextField!
    @IBOutlet weak var job: UITextField!
    @IBOutlet weak var hobby: UITextField!
    @IBOutlet weak var spec: UITextField!
    @IBOutlet weak var pers: UITextField!
    @IBOutlet weak var spot: UITextField!
    
    var email: String?
    var password: String?
    var gender: String?
    var ageFirst: String = ""
    var ageSecond: String = ""
    var imageName: String = ""
    
    var ageFirstList: [String] = ["20", "30"]
    var ageSecondList: [String] = ["f", "m", "l"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inputProfile")
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        //let contact = Profile(entity: entityDescription!, insertInto: managedObjectContext)
        
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                email = match.value(forKey: "email") as? String
                print(email!)
                gender = match.value(forKey: "gender") as? String
                password = match.value(forKey: "password") as? String
                
                print(gender!)
                print(password!)
                
                print(match)
            } else {
                print("nothing founded")
            }
        } catch {
            print("error")
        }

        // Do any additional setup after loading the view.
        
        count = array.count
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(inputProfileViewController.showActionSheet))
        
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        //configureTextField()
        
        navigationItem.hidesBackButton = true
    }
    
    func deleteImage() {
        image.image = nil
    }
    
    func useCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        self.show(picker, sender: nil)
    }
    
    func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.show(picker, sender: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let selectedimage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        image.image = selectedimage
        
    }
    
    func showActionSheet() {
        let alert = UIAlertController(title: "Add Image", message: "Image", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let CameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action -> Void in
            self.useCamera()
        })
        let AlbumAction = UIAlertAction(title: "Album", style: .default, handler: { action -> Void in
            self.addImage()
        })
        let DeleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action -> Void in
            self.deleteImage()
        })
        
        alert.addAction(CameraAction)
        alert.addAction(AlbumAction)
        //alert.addAction(DeleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadImage() {
        
        let imageUrl = URL(string: ohnamiUrl + "/uploads")
        
        let request = NSMutableURLRequest(url : imageUrl!)
        request.httpMethod = "POST"
        
        if image == nil {
            print("image is nil")
        }
        
        var boundary = "******"
        
        let imageData = UIImageJPEGRepresentation(image.image!, 1)
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let mimetype = "image/*"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"board_title\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"images\"; filename=\"\(imageName)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData!)
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard ((data) != nil), let _:URLResponse = response, error == nil else {
                print("error \(error!)")
                return
            }
            
            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                print("response \(response!)")
                print("dataString: \(dataString)")
            }
        })
        task.resume()
        
    }
    
    /*func configureTextField() {
        for i in 0 ... count {
            //print(i)
            let ccount = count + 1
            let myTextField: UITextField = UITextField(frame: CGRect(x:20, y:50 * ccount, width: 280, height: 30))
            myTextField.placeholder = "inputText"
            myTextField.delegate = self
            myTextField.borderStyle = UITextBorderStyle.roundedRect
            //myTextField.layer.borderWidth = 0.5
            //myTextField.layer.borderColor = UIColor.black.cgColor
            self.view.addSubview(myTextField)
        }
    }*/
    @IBAction func valueChanged(_ sender: Any) {
        ageFirst = self.ageFirstList[self.age.selectedSegmentIndex]
        //ageSecond = self.ageSecondList[self.age_part.selectedSegmentIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadData() {
        imageName = email!
        
        let imageName1 = imageName.replacingOccurrences(of: "@", with: "")
        imageName = imageName1.replacingOccurrences(of: ".", with: "")
        
        imageName = imageName + ".jpg"
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        
        let Corerequest = NSFetchRequest<NSFetchRequestResult>()
        Corerequest.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(Corerequest)
            
            if objects.count > 0 {
                let match = objects[0] as! Profile
                match.setValue(nick.text!, forKey: "nick")
                match.setValue(job.text!, forKey: "job")
                match.setValue(pers.text!, forKey: "pers")
                match.setValue(spec.text!, forKey: "spec")
                match.setValue(spot.text!, forKey: "spot")
                match.setValue(hobby.text!, forKey: "hobby")
                match.setValue(ageFirst, forKey: "age")
                //match.setValue(ageSecond, forKey: "age_part")
                match.setValue(imageName, forKey: "imageId")

            } else {
                print("nothing founded")
            }
        } catch {
            print("error")
        }

        let myUrl = URL(string: ohnamiUrl + "/profile")
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String : Any] = ["email" : "\(email!)", "nick" : "\(nick.text!)", "age" : "\(ageFirst)", "job" : "\(job.text!)", "hobby" : "\(hobby.text!)", "spec" : "\(spec.text!)", "pers" : "\(pers.text!)", "spot" : "\(spot.text!)", "imageId1" : "\(imageName)"]
        
        print(json)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request, completionHandler:  {( data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error!)
            }
            self.uploadImage()
            
            self.EvalSegue()
            
        }) .resume()
    }
    
    @IBAction func submit(_ sender: Any) {
        uploadData()
    }
    
    func EvalSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "EvalSegue", sender: self)
        }
    }
    
    func keyboardUp(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
            
            //키보드가 올라올때 뷰를 위로 옮기고 싶은만큼 숫자증가
            self.view.frame.origin.y -= 50
        }
    }
    
    func keyboardDown(notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //키보드를 제자리로
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    //다른곳 터치시 키보드 숨기는 이벤트
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nick.resignFirstResponder()
        job.resignFirstResponder()
        hobby.resignFirstResponder()
        spec.resignFirstResponder()
        pers.resignFirstResponder()
        spot.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
