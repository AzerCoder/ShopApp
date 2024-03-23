//
//  UiImageView+.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 22/03/24.
//

import UIKit

extension UIImageView{
    func loadImage(url: URL)-> URLSessionDownloadTask{
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { url, _, error in
            if error == nil, let url = url{
                if let data = try? Data(contentsOf: url),let image = UIImage(data: data){
                    
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}


