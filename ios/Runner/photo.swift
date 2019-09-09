//
//  photo.swift
//  Runner
//
//  Created by Veasna Sreng on 8/22/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Photos

extension Photo {
    
    init(asset: PHAsset) {
        self.name = asset.originalFilename!
        self.width = Int32(asset.pixelWidth)
        self.height = Int32(asset.pixelHeight)
        self.localIdentifier = asset.localIdentifier
        self.fileSize = 0
    }
    
}

extension Photos {
    
    init(listPhotos: PHFetchResult<PHAsset>) {
        var allPhotos: [Photo] = []
        if (listPhotos.count > 0) {
            listPhotos.enumerateObjects({ (asset, index, up) in
                allPhotos.append(Photo(asset: asset))
            })
        }
        self.photos = allPhotos
    }
    
}
