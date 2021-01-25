//
//  SavedViewController.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import UIKit
import RealmSwift
import SwipeCellKit
import Firebase

class SavedViewController: UIViewController {
    
    let realm = try! Realm()
    
    var savedExhibits: Results<SavedExhibit>?
    
    var urlArray = [String]()
    
    var url = URL(string: "url here")
    var exhibitTitle = "title here"
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: K.cellIdentifier)
        table.backgroundView = UIImageView(image: UIImage(named: "robin-schreiner-YKE4zTW5lic-unsplash"))
        
        return table
    }()
    
    private let searchView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        
//        view.clipsToBounds = true
        return view
    }()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.autocapitalizationType = .none
        bar.autocorrectionType = .no
        bar.returnKeyType = .search
        bar.layer.cornerRadius = 12
        bar.layer.borderWidth = 1
        bar.layer.borderColor = UIColor.lightGray.cgColor
        bar.placeholder = "Find..."
        return bar
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        searchView.frame = CGRect(x: view.left,
                                  y: K.setUI.heightFromTop,
                                 width: view.width,
                                 height: 60)
        
        
        searchBar.frame = CGRect(x: K.setUI.spaceForBar * 4,
                                 y: view.top + K.setUI.spaceForBar,
                                   width: view.width - 80,
                                   height: K.setUI.fieldHeight)
        
        tableView.frame = CGRect(x: view.left,
                                 y: searchView.bottom,
                                 width: view.width,
                                 height: view.bottom - searchView.bottom)
        
    }
    
    
    
    override func viewDidLoad() {
        self.navigationItem.title = "Saved"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
        
        hideKeyboardWhenTappedAround()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableView()
        
        view.addSubview(tableView)
        view.addSubview(searchView)
        searchView.addSubview(searchBar)
        
        self.tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: K.cellIdentifier)
        
        fetchConservations()
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    private func fetchConservations() {
        tableView.isHidden = false
        savedExhibits = realm.objects(SavedExhibit.self).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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
            vc?.titleLabel.text = exhibitTitle
            vc?.imageView.downloaded(from: url!)
            
        }
        
        
    }
    
    func careNoTextInSearchBar(searchBar: UISearchBar) -> Bool {
        
        if searchBar.text?.count == 0 {
            fetchConservations()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            return true
        }else {
            return false
        }
    }
    

}


extension SavedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedExhibits?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        
        if let exhibit = savedExhibits?[indexPath.row] {
            cell.textLabel?.text = exhibit.title
        }else {
            cell.textLabel?.text = "No exhibit added"
        }
        
        cell.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.8)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedExhibit = savedExhibits?[indexPath.row] {
            url = URL(string: selectedExhibit.imgUrl)
            exhibitTitle = selectedExhibit.title
            self.performSegue(withIdentifier: K.segueSavedToImage, sender: self)
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
}






// MARK: - Search bar methods
extension SavedViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard careNoTextInSearchBar(searchBar: searchBar) else {
            
            let exhibitsNotFilteredDuringSearch = realm.objects(SavedExhibit.self).sorted(byKeyPath: "title", ascending: true)
            
            // filter by title
            savedExhibits = exhibitsNotFilteredDuringSearch.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
            
            // filter by date
            //        savedExhibits = exhibitsNotFilteredDuringSearch?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
            return
        }
        
    }
    
}


extension SavedViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if let exhibit = self.savedExhibits?[indexPath.row] {
                do {
                    try self.realm.write{
                        self.realm.delete(exhibit)
                    }
                } catch {
                    print("Error deleting exhibit, \(error)")
                }
            }
            
//            tableView.reloadData()    //! Don't call it. It is already happening.
        }


        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
//        options.transitionStyle = .border
        return options
    }
    
}
