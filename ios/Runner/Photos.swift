//
//  Photos.swift
//  Runner
//
//  Created by Veasna Sreng on 8/21/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Photos
import SwiftProtobuf

//
func GetAllPhoto(_ arg: AnyHashable?, result: @escaping FlutterResult) {
    PHPhotoLibrary.requestAuthorization { (status) in
        switch status {
        case .authorized:
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let listPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            result(ValueWrapper(Photos(listPhotos: listPhotos)))
            break
            
        case .denied, .restricted, .notDetermined:
            result(FlutterError(code: "URPD", message: "Permission denied", details: nil))
            break
            
        default:
            break
        }
    }
}

func GetPhoto(_ arg: Photo?, result: @escaping FlutterResult) {
    guard let photo = arg else {
        result(FlutterError(code: "IMARG", message: "Invalid arguments", details: nil))
        return
    }
    
    PHPhotoLibrary.requestAuthorization { (status) in
        switch status {
        case .authorized:
            let fetchOptions = PHFetchOptions()
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [photo.localIdentifier], options: fetchOptions)
            
            let options = PHImageRequestOptions()
            options.version = .current
            
            let requestTargetSize: CGSize
            let aspect: PHImageContentMode
            if photo.width == 0 || photo.height == 0{
                options.resizeMode = .exact
                requestTargetSize = PHImageManagerMaximumSize
                aspect = .aspectFit
            } else {
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
                options.resizeMode = PHImageRequestOptionsResizeMode.fast
                requestTargetSize = CGSize(width: Double(photo.width), height: Double(photo.height))
                aspect = .aspectFill
            }
            
            PHImageManager.default().requestImage(for: results.firstObject!,
                                                  targetSize: requestTargetSize,
                                                  contentMode: aspect,
                                                  options: options) { (image, _) in
                                                    guard let image = image else { return }

                                                    result(ValueWrapper(UIImageJPEGRepresentation(image, 1.00)))
            }
            break
            
        case .denied, .restricted, .notDetermined:
            result(FlutterError(code: "URPD", message: "Permission denied", details: nil))
            break
            
        default:
            break
        }
    }
}

func GetPhotoMetadata(_ arg: Photo?, result: @escaping FlutterResult) {
    guard let photo = arg else {
        result(FlutterError(code: "IMARG", message: "Invalid arguments", details: nil))
        return
    }
    
    let fetchOptions = PHFetchOptions()
    let results = PHAsset.fetchAssets(withLocalIdentifiers: [photo.localIdentifier], options: fetchOptions)
    let asset = results.firstObject!
    
    let options = PHContentEditingInputRequestOptions()
    options.isNetworkAccessAllowed = true
    
    asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) in
        let filesize = try? contentEditingInput!.fullSizeImageURL!.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize
        let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
        let aMetadata = fullImage!.properties
        
        var pmd = PhotoMetadata.init()
        pmd.fileSize = Int64(filesize!!)
        
        if let date = aMetadata["{IPTC}"] as? NSDictionary,
            let createDateAt = date["DigitalCreationDate"] as? NSString,
            let createTimeAt = date["DigitalCreationTime"] as? NSString {
            
            var dateComponent = DateComponents()
            dateComponent.year = createDateAt.integerValue / 10000
            dateComponent.month = (createDateAt.integerValue % 10000) / 100
            dateComponent.day = createDateAt.integerValue % 100
            dateComponent.hour = createTimeAt.integerValue / 10000
            dateComponent.minute = (createTimeAt.integerValue % 10000) / 100
            dateComponent.second = createTimeAt.integerValue % 100
            
            pmd.captureAt = Int64((Calendar.current.date(from: dateComponent)!.timeIntervalSince1970*1000).rounded())
        }
        
        if let tiff = aMetadata["{TIFF}"] as? NSDictionary,
            let company = tiff["Make"] as? NSString {
            pmd.make = company as String
        }
        
        if let gps = aMetadata["{GPS}"] as? NSDictionary,
            let latitude = gps["Latitude"] as? NSNumber,
            let longitude = gps["Longitude"] as? NSNumber {
            pmd.location = Location()
            pmd.location.latitude = Double(truncating: latitude)
            pmd.location.longitude = Double(truncating: longitude)
        }
        
        result(ValueWrapper(pmd))
    }
}

func RemovePhotoMetadata(_ arg: Photo?, result: @escaping FlutterResult) {
    let fetchOptions = PHFetchOptions()
    let results = PHAsset.fetchAssets(withLocalIdentifiers: [arg!.localIdentifier], options: fetchOptions)
    let asset = results.firstObject!

    PHPhotoLibrary.shared().performChanges({
        let assetRequest = PHAssetChangeRequest.init(for: asset)
        // remove all sensitive data
        assetRequest.location = CLLocation(latitude: 0, longitude: 0)
    }) { (success: Bool, error: Error?) in
        result(ValueWrapper(success))
    }
}
