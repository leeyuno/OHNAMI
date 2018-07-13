//
//  waitingViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 25/05/2017.
//  Copyright © 2017 Froglab. All rights reserved.
//

import UIKit

class waitingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //@IBOutlet weak var image1: UIImageView!
    //@IBOutlet weak var image2: UIImageView!
    
    //var tapNumber = 0
    
    @IBOutlet weak var submitButton: UIButton!
    
    let count = 0
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        
        //평가 조건이 만족하면 버튼이 활성화
//        if count < 10 {
//            submitButton.isEnabled = false
//        } else {
//            submitButton.isEnabled = true
//        }
    }

    @IBAction func submitButton(_ sender: Any) {
        EvalSuccessSegue()
    }
    
    func EvalSuccessSegue() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "EvalSuccessSegue", sender: self)
        }
    }

}

        // Do any additional setup after loading the view.
        
        /*let tapImage1 = UITapGestureRecognizer(target: self, action: #selector(waitingViewController.tapImage1))
        let tapImage2 = UITapGestureRecognizer(target: self, action: #selector(waitingViewController.tapImage2))
        
        image1.isUserInteractionEnabled = true
        image1.addGestureRecognizer(tapImage1)
        
        image2.isUserInteractionEnabled = true
        image2.addGestureRecognizer(tapImage2)
        
        navigationItem.hidesBackButton = true
        
        navigationItem.hidesBackButton = true
        
    }
    
    func tapImage1() {
        tapNumber = 1
        showActionSheet()
    }
    
    func tapImage2() {
        tapNumber = 2
        showActionSheet()
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
    
    func deleteImage() {
        if tapNumber == 1 {
            image1.image = nil
        }
            
        else {
            image2.image = nil
        }
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
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if tapNumber == 1 {
            image1.image = image
        }
            
        else {
            image2.image = image
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}*/
