//
//  NoticeViewController.swift
//  OhNaMi
//
//  Created by leeyuno on 2017. 8. 4..
//  Copyright © 2017년 Froglab. All rights reserved.
//

import UIKit
import CoreData

class NoticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var noticeTableView: UITableView!
    @IBOutlet weak var noticeTextLabel: UILabel!
    
    //var noticeList = [String]()
    var noticeList = ["공지사항1", "공지사항2", "공지사항3", "공지사항4", "공지사항5"]
    
    var email: String!

    @IBOutlet var detailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "공지사항"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        do {
            let objects = try managedObjectContext.fetch(request)
            
            if objects.count > 0 {
                let match = objects[0] as? Profile
                email = match?.value(forKey: "email") as! String
            } else {
                print("Nothing founded")
            }
        } catch {
            print("error")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureTableView()
        //self.receiveNotice()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView() {
        noticeTableView.delegate = self
        noticeTableView.dataSource = self
    }
    
    func receiveNotice() {
        let noticeUrl = URL(string: ohnamiUrl + "/notice")
        var request = URLRequest(url: noticeUrl!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let json : [String : Any] = ["email" : "email"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                if (error?.localizedDescription)! == "The request timed out." {
                    let alert = UIAlertController(title: "서버에 접속할 수 없습니다.", message: "다시 시도해 주세요", preferredStyle: .alert)
                    let done = UIAlertAction(title: "확인", style: .default, handler: { action -> Void in
                        exit(0)
                    })
                    
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                do {
                    let parseJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    //print(parseJSON)
                } catch {
                    print("error")
                }
            }
        }) .resume()
        
    }
    
    func backButtonTapped() {
        print("button Tapped")
        self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
        
        //self.present((self.view.window?.rootViewController)!, animated: true, completion: nil)
    }
    
    func showDetailView() {
        detailView.frame = CGRect(x: self.view.frame.origin.x, y: (self.navigationController?.navigationBar.frame.size.height)!, width: self.view.frame.size.width, height: self.view.frame.size.height)
        detailView.tag = 1
        
        self.view.addSubview(detailView)
    }
    
    @IBAction func backButton(_ sender: Any) {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) 
        
        cell.textLabel?.text = noticeList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
