//
//  ImageViewController.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import UIKit

import UIKit
import WebKit

class ImageViewController: UIViewController {
    
    private let imageAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.85)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.0)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.textAlignment = .center
        
        
        return label
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageAreaView.frame = CGRect(x: 20,
                                     y: view.top + 30,
                                     width: view.width - 40,
                                     height: view.bottom - 360)
        imageAreaView.addDashedBorder()
        
        imageView.frame = CGRect(x: 20,
                                 y: view.top + 30,
                                 width: view.width - 40,
                                 height: view.bottom - 400)
        
        titleLabel.frame = CGRect(x: 25,
                                 y: imageView.bottom + 10,
                                 width: view.width - 50,
                                 height: 20)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.95)
        
        view.addSubview(imageAreaView)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
    }
    
    
    
    
}

