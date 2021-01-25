//
//  MuseumData.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import Foundation

struct MuseumObjectData: Codable {
    let total: Int
    let objectIDs: [Int]
}


struct MuseumObjectDetailData: Codable {
    let primaryImage: URL
    let title: String
}
