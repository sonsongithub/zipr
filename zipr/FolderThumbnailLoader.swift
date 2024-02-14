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

public extension Array where Element: Equatable {
    @discardableResult
    mutating func find(_ element: Element) -> Bool {
        guard let _ = firstIndex(of: element) else { return false }
        return true
    }
    
    mutating func removeAllWith(_ element: Element) -> Void {
        removeAll { (str) -> Bool in
            str == element
        }
    }
}

class FolderThumbnailLoader {
    let semaphoreDispatchQueue = DispatchQueue(label: String(Date.timeIntervalSinceReferenceDate))
    let taskDispatchQueue = DispatchQueue.global()
    
    var queue: [String] = []
    var process: [String] = []
    
    var cancelFlag = false
    
    let max = Int(4)
    
    deinit {
        print("deinit FolderThumbnailLoader")
    }
    
    
    func cacheURL(_ path: String) -> URL? {
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
    
    func cache(_ path: String, startLoading: Bool = false) -> UIImage? {
        guard let imageURL = cacheURL(path) else { return nil }
        if let image = UIImage(contentsOfFile: imageURL.path) {
            return image
        }
        if startLoading {
            append(path)
        }
        return nil
    }
    
    func append(_ path: String) {
        semaphoreDispatchQueue.async {
            if !self.queue.find(path) && !self.process.find(path) {
                self.queue.append(path)
            }
        }
        self.pop()
    }
    
    func cancel_path(_ path: String) {
        semaphoreDispatchQueue.async {
            self.queue.removeAll { (str) -> Bool in
                return (path == str)
            }
        }
    }
    
    func clear() {
        self.cancelFlag = true
        self.queue.removeAll()
    }
    
    func pop() {
        print("Try to pop. current queue = " + String(self.queue.count))
        if self.process.count == max {
            return
        }
        semaphoreDispatchQueue.async {
            if let target = self.queue.popLast() {
                self.process.append(target)
                self.taskDispatchQueue.async {
                    defer {
                        self.semaphoreDispatchQueue.async {
                            self.process.removeAllWith(target)
                        }
                        print("Done! current queue = " + String(self.queue.count))
                        DispatchQueue.main.async {
                            self.pop()
                        }
                    }
                    
                    let handler = FileHandle(forReadingAtPath: target)
                    
                    guard !self.cancelFlag else { return }
                    
                    var buffer = Data(capacity: 1024 * 1024 * 100)
                    
                    let fileSize = -1
                    
                    let readLength = 1024 * 1024 * 10
                    
                    for i in 0..<1024 {
                        if let tempReadData = handler?.readData(ofLength: readLength) {
                            buffer.append(tempReadData)
                            print("Read - " + String(buffer.count) + "/" + String(fileSize))
                            if tempReadData.count < readLength {
                                break
                            }
                        } else {
                            break
                        }
                        guard !self.cancelFlag else { return }
                    }
                    
                    guard let archive = Archive(data: buffer, accessMode: .read, preferredEncoding: .shiftJIS) else {
                        return
                    }
                    
                    let entries = archive.extractOrderedContents()
        
                    print("Start to decode - " + (target as NSString).lastPathComponent)
        
                    if let entry = entries.first {
                        var imageBuffer = Data()
                        do {
                            _ = try archive.extract(entry, bufferSize: 20480, skipCRC32: true, progress: nil, consumer: { (data) in
                                imageBuffer.append(data)
                            })
                            guard let image = UIImage(data: imageBuffer) else { return }
                            let userInfo: [String: Any] = ["image": image, "path": target]
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("ZipThumbnail"), object: nil, userInfo: userInfo)
                            }
                            guard let cacheURL = self.cacheURL(target) else { return }
                            try imageBuffer.write(to: cacheURL)
                        } catch {
                            print(error)
                            return
                        }
                    }
                }
            }
        }
    }
}

var counter = 0

class FolderThumbnailLoader2 {
    let semaphoreQueue = DispatchQueue(label: String(Date.timeIntervalSinceReferenceDate))
    let load_quque = DispatchQueue.global()
    let semaphore = DispatchSemaphore(value: 2)
    var buffer: [String] = []
    var current: String? = nil
    
    var taskTable: [String: String] = [:]
    
    var taskBuffer: [String] = []
    
    var cancelFlag = false
    
    init() {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        if var cacheURL = urls.first {
            cacheURL.appendPathComponent("zip_thumbnail")
            do {
                try FileManager.default.removeItem(at: cacheURL)
            } catch {
                print(error)
            }
        }
    }
    
    deinit {
        print("deinit FolderThumbnailLoader")
    }
    
    func clear() {
        print("clear - FolderThumbnailLoader")
        self.cancelFlag = true
        self.taskBuffer.removeAll()
    }
    
    func cacheURL(_ path: String) -> URL? {
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
    
    func cache(_ path: String, startLoading: Bool = false) -> UIImage? {
        guard let imageURL = cacheURL(path) else { return nil }
        if let image = UIImage(contentsOfFile: imageURL.path) {
            return image
        }
        if startLoading {
            append(path)
        }
        return nil
    }
    
    var cancel_buffer: [String] = []
    
    func cancel_path(_ path: String) {
        self.taskBuffer.removeAll { (str) -> Bool in
            return (path == str)
        }
    }
    
    func append(_ path: String) {
            
        var existsFlag = false
        
        
        semaphoreQueue.sync {
            
            if let _ = self.taskBuffer.first(where: { (str) -> Bool in
                return str == path
            }) {
                existsFlag = true
            } else {
                self.taskBuffer.append(path)
            }
        }
        
        guard !existsFlag else { return }
        
        load_quque.async {
            
            counter += 1
            defer {
                counter -= 1
                self.semaphore.signal()
                self.cancel_path(path)
            }
            
            self.semaphore.wait()
            
            guard let _ = self.taskBuffer.first(where: { (str) -> Bool in
                    return str == path
                }) else {
                    return
                }
            
            guard !self.cancelFlag else { return }
            
            guard let cacheURL = self.cacheURL(path) else { return }
            
            guard !FileManager.default.fileExists(atPath: cacheURL.path) else { return }
            
            let handler = FileHandle(forReadingAtPath: path)
            
            var fileSize: UInt64 = 0
            
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: path)
                if let tempFileSize = attr[.size] as? UInt64 {
                    fileSize = tempFileSize
                }
            } catch {
                print(error)
                return
            }
            
            var buffer = Data(capacity: 1024 * 1024 * 100)
            
            let readLength = 1024 * 1024 * 10
            
            Thread.sleep(forTimeInterval: 4)
            
//            for i in 0..<1024 {
//                if let tempReadData = handler?.readData(ofLength: readLength) {
//                    buffer.append(tempReadData)
//                    print("Read - " + String(buffer.count) + "/" + String(fileSize))
//                    if tempReadData.count < readLength {
//                        break
//                    }
//                } else {
//                    break
//                }
//                guard let _ = self.taskBuffer.first(where: { (str) -> Bool in
//                        return str == path
//                    }) else {
//                        break
//                    }
//                guard !self.cancelFlag else { break }
//            }
            print("Start to decode - " + (path as NSString).lastPathComponent)
//
//            guard let archive = Archive(data: buffer, accessMode: .read, preferredEncoding: .shiftJIS) else {
//                return
//            }
//
//            let entries = archive.extractOrderedContents()
//
//            print("Start to decode - " + (path as NSString).lastPathComponent)
//
//            if let entry = entries.first {
//                var imageBuffer = Data()
//                do {
//                    _ = try archive.extract(entry, bufferSize: 20480, skipCRC32: true, progress: nil, consumer: { (data) in
//                        imageBuffer.append(data)
//                    })
//                    guard let image = UIImage(data: imageBuffer) else { return }
//                    let userInfo: [String: Any] = ["image": image, "path": path]
////                    DispatchQueue.main.async {
////                        NotificationCenter.default.post(name: Notification.Name("ZipThumbnail"), object: nil, userInfo: userInfo)
////                    }
//                    try imageBuffer.write(to: cacheURL)
//                } catch {
//                    print(error)
//                    return
//                }
//            }
        }
    }
}
