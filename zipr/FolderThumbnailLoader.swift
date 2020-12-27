//
//  FolderThumbnailLoader.swift
//  zipr
//
//  Created by sonson on 2020/12/25.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import UIKit
import ZIPFoundation

//protocol FolderThumbnailLoaderDelegate {
//}

class FolderThumbnailLoader {
    let semaphoreQueue = DispatchQueue(label: String(Date.timeIntervalSinceReferenceDate))
    let load_quque = DispatchQueue.global()
    let semaphore = DispatchSemaphore(value: 2)
    var buffer: [String] = []
    var current: String? = nil
    
    var cancelFlag = false
    
    deinit {
        print("deinit FolderThumbnailLoader")
    }
    
    func clear() {
        semaphoreQueue.sync {
            self.cancelFlag = true
        }
    }
    
    func getCachePath(_ path: String) -> URL? {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard var cacheURL = urls.first else { return nil }
        
        cacheURL.appendPathComponent("zip_thumbnail")
        
        do {
            try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
            return nil
        }
        let hash: String = path.digest(type: .sha256)
        return cacheURL.appendingPathComponent(hash)
    }
    
    func cache(_ path: String) -> UIImage? {
        guard let imageURL = getCachePath(path) else { return nil }
        if let image = UIImage(contentsOfFile: imageURL.path) {
            return image
        }
        return nil
    }
    
    func append(_ path: String) {
        
        load_quque.async {
            defer { self.semaphore.signal() }
            
            self.semaphore.wait()
            
            guard !self.cancelFlag else { return }
            
            guard let cacheURL = self.getCachePath(path) else { return }
            
            guard !FileManager.default.fileExists(atPath: cacheURL.path) else { return }
            
            let fileURL = URL(fileURLWithPath: path)
            guard let archive = Archive(url: fileURL, accessMode: .read, preferredEncoding: String.Encoding.shiftJIS) else {
                return
            }
            let entries = archive.extractOrderedContents()

            if let entry = entries.first {
                var d = Data()
                do {
                    _ = try archive.extract(entry, bufferSize: 20480, skipCRC32: true, progress: nil, consumer: { (data) in
                        d.append(data)
                    })
                    if let image = UIImage(data: d) {
                        try! d.write(to: cacheURL)
                        let userInfo: [String: Any] = [
                            "image": image,
                            "path": path
                        ]
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("ZipThumbnail"), object: nil, userInfo: userInfo)
                        }
                    }
                } catch {
                    print(error)
                    return
                }
            }
        }
    }
}
