//
//  MuseumManager.swift
//  We II Cultured
//
//  Created by ONUR AKDOGAN on 21.01.2021.
//

import Foundation
import UIKit

protocol MuseumManagerDelegate {
    func didGetObject(_ museumManager: MuseumManager, museum: MuseumObjectModel)
    func didGetObjectDetail(_ museumManager: MuseumManager, exhibit: ExhibitionModel)
    func didFailWithError(error: Error)
}


struct MuseumManager {

    let objectURL = "https://collectionapi.metmuseum.org/public/collection/v1/search?title=true&isOnView=true&hasImage=true"
    
    let objectDetailURL = "https://collectionapi.metmuseum.org/public/collection/v1/objects/"
    
    var delegate: MuseumManagerDelegate?
    
    func fetchObjects(words: String) {
        let urlString = "\(objectURL)&q=\(words)"
        performObjectRequest(with: urlString)
    }
    
    func fetchObjectDetail(objectID: Int) {
        let urlString = "\(objectDetailURL)\(objectID)"
        performRequestDetail(with: urlString)
    }
    
    
    
    func performObjectRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let museum = self.parseMuseumObjectJSON(safeData) {
                        self.delegate?.didGetObject(self, museum: museum)

                        
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func performRequestDetail(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let exhibit = self.parseMuseumObjectDetailJSON(safeData) {
                        self.delegate?.didGetObjectDetail(self, exhibit: exhibit)

                    }
                }
            }
            task.resume()
        }
    }
    
    func parseMuseumObjectJSON(_ museumObjectData: Data) -> MuseumObjectModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(MuseumObjectData.self, from: museumObjectData)
            
            let totalArt = decodedData.total
            let objectIDs = decodedData.objectIDs

            let museumObject = MuseumObjectModel(numberOfObjects: totalArt, objectIDs: objectIDs)
            return museumObject
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseMuseumObjectDetailJSON(_ museumObjectDetailData: Data) -> ExhibitionModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(MuseumObjectDetailData.self, from: museumObjectDetailData)
            
            let url = decodedData.primaryImage
            let title = decodedData.title

            let museumObjectDetail = ExhibitionModel(imageUrl: url, title: title)
            return museumObjectDetail
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        DispatchQueue.main.async() {
            self.contentMode = mode
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                
                else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
            
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
