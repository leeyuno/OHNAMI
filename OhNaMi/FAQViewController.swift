//
//  FAQViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 8. 5..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerView = UIPickerView()
    var pickItem = ["신고", "버그", "기타"]

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var TextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurePickerView()

        // Do any additional setup after loading the view.
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        
        self.navigationItem.leftBarButtonItem = backButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func configurePickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextField.inputView = pickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(FAQViewController.donePressed(sender:)))
        let cancelButton = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(FAQViewController.cancelPressed(sender:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        categoryTextField.inputAccessoryView = toolBar
        
    }
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitButton(_ sender: Any) {
        self.sendEmail()
    }
    
    func sendEmail() {
        let adminEmail = "sface_official@gmail.com"
    }
    
    func cancelPressed(sender: UIBarButtonItem) {
        categoryTextField.text = ""
        
        categoryTextField.resignFirstResponder()
    }
    
    func donePressed(sender: UIBarButtonItem) {
        pickerView.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickItem.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickItem[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = pickItem[row]
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
