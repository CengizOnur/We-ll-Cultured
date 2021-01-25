//
//  Constants.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 24.01.2021.
//

import UIKit

struct K {
    
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let segueSavedToImage = "SavedToImageView"
    static let chatToImage = "ChatToImageView"
    
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
        static let userNameField = "userName"
        static let containsUrl = "hasUrl"

    }

    
    struct setUI {
        
        let bounds = UIScreen.main.bounds
        
        // textfield or bars
        static let fieldHeight = UIScreen.main.bounds.size.height * 0.05
        static let fieldWidthLong = UIScreen.main.bounds.size.width * 0.85
        
        // spaces
        static let spaceForBar = UIScreen.main.bounds.size.height * 0.01
        static let spaceBetweenFields = UIScreen.main.bounds.size.height * 0.02
        static let heightFromTop = UIScreen.main.bounds.size.height * 0.095
        
    }
    
}



