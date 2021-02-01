//
//  DiscoverViewController.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import UIKit
import RealmSwift
import JGProgressHUD
import Firebase

class DiscoverViewController: UIViewController {
    
    let realm = try! Realm()
    
    var objectIDs = [Int]()
    var objectCount = 0
    
    var museumManager = MuseumManager()
    var exhibitionModel: ExhibitionModel? = nil
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private let searchField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .search
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Discover ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .systemBackground
        return field
    }()
    
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        return button
    }()
    
    private let imageAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.85)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        return button
    }()
    
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.width, height: view.height)
        
        searchField.frame = CGRect(x: K.setUI.spaceBetweenFields,
                                   y: K.setUI.spaceBetweenFields * 4,
                                   width: view.width - (K.setUI.spaceBetweenFields * 2 * 3),
                                   height: K.setUI.fieldHeight)
        
        searchButton.frame = CGRect(x: searchField.right + K.setUI.spaceBetweenFields,
                                    y: searchField.top,
                                    width: (view.width - searchField.right) - (K.setUI.spaceBetweenFields * 2),
                                    height: K.setUI.fieldHeight)
        
        
        imageAreaView.frame = CGRect(x: K.setUI.spaceBetweenFields,
                                     y: searchField.bottom + K.setUI.spaceBetweenFields,
                                     width: view.width - (K.setUI.spaceBetweenFields * 2),
                                     height: view.height * 0.5)
        imageAreaView.addDashedBorder()
        
        
        
        imageView.frame = CGRect(x: K.setUI.spaceBetweenFields,
                                 y: searchField.bottom + K.setUI.spaceBetweenFields,
                                 width: view.width - (K.setUI.spaceBetweenFields * 2),
                                 height: imageAreaView.bottom - imageAreaView.top - K.setUI.spaceBetweenFields * 4)
        
        titleLabel.frame = CGRect(x: K.setUI.spaceBetweenFields + 10,
                                 y: imageView.bottom + K.setUI.spaceBetweenFields,
                                 width: view.width - (K.setUI.spaceBetweenFields + 10) * 2,
                                 height: imageAreaView.bottom - (imageView.bottom + K.setUI.spaceBetweenFields))
        
        
        previousButton.frame = CGRect(x: K.setUI.spaceBetweenFields,
                                      y: imageAreaView.bottom + K.setUI.spaceBetweenFields,
                                      width: K.setUI.spaceBetweenFields * 3,
                                      height: K.setUI.spaceBetweenFields * 2)
        
        shareButton.frame = CGRect(x: previousButton.right + K.setUI.spaceBetweenFields,
                                   y: imageAreaView.bottom + K.setUI.spaceBetweenFields,
                                   width: K.setUI.spaceBetweenFields * 4,
                                   height: K.setUI.spaceBetweenFields * 3)
        
        nextButton.frame = CGRect(x: view.right - K.setUI.spaceBetweenFields - (K.setUI.spaceBetweenFields * 3),
                                  y: imageAreaView.bottom + K.setUI.spaceBetweenFields,
                                  width: K.setUI.spaceBetweenFields * 3,
                                  height: K.setUI.spaceBetweenFields * 2)
        
        saveButton.frame = CGRect(x: nextButton.left - K.setUI.spaceBetweenFields - (K.setUI.spaceBetweenFields * 4),
                                  y: imageAreaView.bottom + K.setUI.spaceBetweenFields,
                                  width: K.setUI.spaceBetweenFields * 4,
                                  height: K.setUI.spaceBetweenFields * 3)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "markus-spiske-4W5WWKaxsKs-unsplash")!)
        }

        // navigation
        self.navigationItem.title = "Exhibition"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
        
        // keyboard
        self.hideKeyboardWhenTappedAround()
        
        // delegates
        museumManager.delegate = self
        searchField.delegate = self
        
        // add subviews
        view.addSubview(scrollView)
        
        scrollView.addSubview(searchField)
        scrollView.addSubview(searchButton)
        scrollView.addSubview(imageAreaView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(nextButton)
        scrollView.addSubview(previousButton)
        scrollView.addSubview(shareButton)
        scrollView.addSubview(saveButton)
        
        // addtargets
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // hide buttons
        buttonsAreNotAvailable()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    

    
    // functions
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    
    @objc private func searchButtonTapped() {
        
        objectCount = 0
        
        if let words = searchField.text {
            
            guard words != "" else {
                searchField.placeholder = "Type something"
                return
            }
            museumManager.fetchObjects(words: words)
            
        }
        
        searchField.text = ""
        dismissKeyboard()
        
    }
    
    @objc private func nextButtonTapped(_ sender: Any) {
        
        objectCount += 1
        
        if objectCount == objectIDs.count {
            objectCount = 0
        }
        
        museumManager.fetchObjectDetail(objectID: objectIDs[objectCount])
        
    }
    
    @objc private func previousButtonTapped(_ sender: Any) {
        
        objectCount -= 1
        
        if objectCount == -1 {
            objectCount = objectIDs.count - 1
        }
        
        museumManager.fetchObjectDetail(objectID: objectIDs[objectCount])
        
    }
    
    
    @objc private func shareButtonTapped(_ sender: Any) {
        
        let navController = self.tabBarController?.viewControllers![1] as! UINavigationController
        let chatRoomViewController = navController.topViewController as! ChatRoomViewController
        
        
        if let safeExhibitionModel = exhibitionModel {
            if let safeUrl = exhibitionModel?.imageUrl {
                let imageUrlString = safeUrl
                let objectTitle = safeExhibitionModel.title
                
                let messageBody = "\(objectTitle) => \(imageUrlString)"
                chatRoomViewController.messagesShared.append(messageBody)

            }
            
        }
        
    }
    
    @objc private func saveButtonTapped(_ sender: Any) {
        
        if let safeExhibitionModel = exhibitionModel {
            if let safeUrl = exhibitionModel?.imageUrl {
                let imageUrlString = safeUrl
                let objectTitle = safeExhibitionModel.title

                do {
                    try self.realm.write {
                        let newExhibitToSave = SavedExhibit()
                        newExhibitToSave.imgUrl = imageUrlString.absoluteString
                        newExhibitToSave.title = objectTitle
                        realm.add(newExhibitToSave)
                    }
                }catch {
                    print("Error saving exhibits, \(error)")
                }

            }
        }
        
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
    
    private func buttonsAreNotAvailable() {
        nextButton.isHidden = true
        previousButton.isHidden = true
        shareButton.isHidden = true
        saveButton.isHidden = true
    }
    
    private func buttonsAreAvailable() {
        nextButton.isHidden = false
        previousButton.isHidden = false
        shareButton.isHidden = false
        saveButton.isHidden = false
    }

}

//MARK: - MuseumManagerDelegate

extension DiscoverViewController: MuseumManagerDelegate {
    
    func didFailWithError(error: Error) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Sorry, no result found", message: nil, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    func didGetObject(_ museumManager: MuseumManager, museum: MuseumObjectModel) {
        
        self.objectIDs = museum.objectIDs
        
        museumManager.fetchObjectDetail(objectID: objectIDs[0])
        
    }
    
    
    func didGetObjectDetail(_ museumManager: MuseumManager, exhibit: ExhibitionModel) {
        
        let imageUrl = exhibit.imageUrl
        let objectTitle = exhibit.title
        
        
        DispatchQueue.main.async {
            self.buttonsAreAvailable()
            self.titleLabel.text = objectTitle
        }
        
        exhibitionModel = ExhibitionModel(imageUrl: imageUrl, title: objectTitle)
        imageView.downloaded(from: imageUrl)
        
    }
}


//MARK: - UITextFieldDelegate
extension DiscoverViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchField {
            searchButtonTapped()
        }
        return true
    }
    
}



