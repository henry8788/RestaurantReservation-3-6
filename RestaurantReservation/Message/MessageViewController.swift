//
//  MessageViewController.swift
//  RestaurantReservation
//
//  Created by Peggy Tsai on 2018/7/13.
//  Copyright © 2018年 Peggy Tsai. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    let communicator = Communicator()
    var array: [MessageInfo] = []
    var array_img: [UIImage] = []
    var member_name: String?
    var member_id: Int?
    
    @IBOutlet weak var messageShowTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        member_name = "hello!"
        member_id = 1
        
        messageShowTableView.refreshControl = UIRefreshControl()
        messageShowTableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
        messageShowTableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
    }
    
    @objc func handleRefresh(){
        getData()
        messageShowTableView.refreshControl?.endRefreshing()
        messageShowTableView.reloadData()
    }
    
    func getData(){
        communicator.doPost1(url: MESSAGE_URL, ["action": "getAll"]) { (error, data) in
            guard let data = data else{
                return
            }
            guard let output = try? JSONDecoder().decode([MessageInfo].self, from: data) else {
                assertionFailure("get output fail")
                return
            }
            
            print("array.count: \(self.array.count)")
            self.array = output
            self.getImage()
        }
    }
    
    func getImage(){
        for x in 0..<self.array.count {
            let id = self.array[x].id
            print("array[x].id: \(id)")
            communicator.doPost1(url: MESSAGE_URL, ["action": "getImage", "id": id , "imageSize": 375]) { (error, data) in
                guard let data = data else{
                    return
                }
                if let image = UIImage(data: data) {
                    self.array_img.append(image)
                    self.messageShowTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? MessageDetailViewController
        
        if let row = messageShowTableView.indexPathForSelectedRow?.row {
            controller?.messageInfo = array[row]
            controller?.messageImage = array_img[row]
            
        }
        
    }
    
    @IBAction func serviceBtnPressed(_ sender: Any) {
        
        UserDefaults.standard.set("8", forKey: MemberKey.TableNumber.rawValue)
        guard let tableNumber = UserDefaults.standard.string(forKey: MemberKey.TableNumber.rawValue) else {
            let alertController = UIAlertController(title: "測試", message: "尚未入座", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
            return
        }
        let alertController = UIAlertController(title: "測試", message: tableNumber, preferredStyle: .alert)
        let action = UIAlertAction(title: "確定", style: .default)
        alertController.addAction(action)
        
        var service = [String: Any]()
        service["action"] = "callService"
        service["tableNumber"] = tableNumber
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: service), let jsonString = String(data: jsonData, encoding: .utf8) else {
            assertionFailure("Data to strint fail!")
            return
        }
        
        commonWebSocketClient?.sendMessage(jsonString)
        
        present(alertController, animated: true)
    }
}

extension MessageViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as! MessageTableViewCell
        let messageContent = array[indexPath.row].message_content
        if array_img.count == array.count{
            //            print("Array Image Count : \(array_img.count),IndexPathRow : \(indexPath.row)")
            let messageImage = array_img[indexPath.row]
            cell.messageImageView.image = messageImage
        }
        cell.messageContentLabel.text = messageContent
        return cell
    }
    
}
