//
//  UIImageViewExtensions.swift
//  BJJTV
//
//  Created by BenRussell on 5/5/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit


extension UIImageView {
    
    func downloadImageFromUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) -> Void in
            if let imageData = data {
                let startImage: UIImage = UIImage(data: imageData as Data)!
                let thumbnailSize = CGSize(width: 128,height: 128);
                var scaledSize = thumbnailSize
                let imageAspectRatio = startImage.size.height / startImage.size.width
                let thumbnailAspectRatio = thumbnailSize.height/thumbnailSize.width
                if (imageAspectRatio >= thumbnailAspectRatio) {
                    scaledSize.width = scaledSize.height * thumbnailSize.width / thumbnailSize.height;
                } else {
                    scaledSize.height = scaledSize.width * imageAspectRatio;
                }
                
                UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
                let scaledImageRect = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
                startImage.draw(in: scaledImageRect)
                let destImage = UIGraphicsGetImageFromCurrentImageContext()
                self?.image = destImage
                UIGraphicsEndImageContext()
            } else {
                return
            }
            
        }).resume()
    }
    
}
