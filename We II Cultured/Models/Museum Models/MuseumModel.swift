//
//  MuseumModel.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import Foundation
import RealmSwift

struct MuseumObjectModel {
    let numberOfObjects: Int
    let objectIDs: [Int]
}

struct ExhibitionModel {
    let imageUrl: URL
    let title: String
}


class SavedExhibit: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var imgUrl: String = ""
}
