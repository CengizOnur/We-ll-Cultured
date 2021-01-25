//
//  ChatRoomViewController.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import Foundation
import UIKit
import Firebase

class ChatRoomViewController: UIViewController {
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    var messagesShared = [String]()     //  from DiscoverViewControl
    var messages: [Message] = []
    
    var tappedMessage = "message here"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .bold)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        self.navigationItem.title = "Chat Room"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
        
        DispatchQueue.main.async {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "adrianna-geo-1rBg5YSi00c-unsplash"))
        }
        
        // Keyboard
        self.hideKeyboardWhenTappedAround()
        messageTextField.delegate = self
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        messageTextField.layer.cornerRadius = messageTextField.frame.size.height / 2.5
        
        // Add messages from DiscoverViewControl to Firebase
        if !messagesShared.isEmpty {
            
            for message in messagesShared {
                addNewMessage(message: message, hasUrl: true)
            }
            
        }
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        fetchMessages()


    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        messagesShared.removeAll()
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchMessages() {
        tableView.isHidden = false
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            
            self.messages = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore, \(e)")
            }else {
                if let snapShotDocuments = querySnapshot?.documents {
                    for doc in snapShotDocuments {
                        let data = doc.data()
                        if let messageSenderEmail = data[K.FStore.senderField] as? String, let message = data[K.FStore.bodyField] as? String, let senderUserName = data[K.FStore.userNameField] as? String, let hasUrl = data[K.FStore.containsUrl] as? Bool {
                            
                            let newMessage = Message(senderEmail: messageSenderEmail, senderName: senderUserName, body: message, containsUrl: hasUrl)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }

            }
        }
    }
    
    
    @objc func sendButtonTapped() {
        
        guard messageTextField.text != "" else {
            return
        }
        
        if let messageBody = messageTextField.text {
            addNewMessage(message: messageBody, hasUrl: false)
        }
        
    }
    
    private func addNewMessage(message: String, hasUrl: Bool) {
        
        if let senderEmail = Auth.auth().currentUser?.email, let senderName = defaults.object(forKey: "userName"){

            db.collection(K.FStore.collectionName).addDocument(data:
                                                                [K.FStore.senderField: senderEmail, K.FStore.bodyField: message, K.FStore.dateField: Date().timeIntervalSince1970,
                                                                 K.FStore.userNameField: senderName,
                                                                 K.FStore.containsUrl: hasUrl]) { (error) in
                if let e = error {
                    print("There was an issue saving data to Firestore, \(e)")
                }else {
                    print("Successfuly saved data.")
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                }
            }

        }
    }
    
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    @objc private func logOutTapped(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            
            let vc = LoginViewController()
            vc.title = "Log In"
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageViewController
        {
            let vc = segue.destination as? ImageViewController
            
            let tappedMessageArray = tappedMessage.components(separatedBy: " => ")
            let title = tappedMessageArray[0]
            let urlString = tappedMessageArray[1]
            let url = URL(string: urlString)
            
            vc?.titleLabel.text = title
            vc?.imageView.downloaded(from: url!)
            
        }
    }
    
}


extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.messageLabel.text = messages[indexPath.row].body
        
        let message = messages[indexPath.row]
        
        var selectedMessageUrl: String?
        
        if message.containsUrl {
            selectedMessageUrl = message.body.components(separatedBy: " => ")[1]
        }
        
        let isUrl = verifyUrl(urlString: selectedMessageUrl)
        
        if isUrl {
            cell.isUserInteractionEnabled = true
            cell.messageLabel.textColor = .systemBlue

        }else {
            cell.isUserInteractionEnabled = false
            cell.messageLabel.textColor = .black
        }
        
        // you or s/he
        if message.senderEmail == Auth.auth().currentUser?.email {
            cell.leftView.isHidden = true
            cell.rightView.isHidden = false
            cell.messageBubbleView.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            cell.rightLabel.text = message.senderName
        }else {
            cell.leftView.isHidden = false
            cell.rightView.isHidden = true
            cell.messageBubbleView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            cell.leftLabel.text = message.senderName
        }
        
        cell.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMessage = messages[indexPath.row]
        
        if selectedMessage.containsUrl {
            tappedMessage = selectedMessage.body
        }
        
        self.performSegue(withIdentifier: K.chatToImage, sender: self)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}


//MARK: - UITextFieldDelegate
extension ChatRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageTextField {
            sendButtonTapped()
        }
        return true
    }

}
