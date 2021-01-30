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

var remained = 0

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
                self.pop()
            }
        }
    }
    
    func cancel_path(_ path: String) {
        semaphoreDispatchQueue.async {
            self.queue.removeAll { (str) -> Bool in
                return (path == str)
            }
        }
    }
    
    func restart() {
        print("Clear")
        semaphoreDispatchQueue.async {
            self.cancelFlag = false
        }
    }
    
    func clear() {
        print("Clear")
        semaphoreDispatchQueue.async {
            self.cancelFlag = true
            self.queue.removeAll()
            print("----Clear")
        }
    }
    
    func pop() {
        print("remained = " + String(remained))
        print("Try to pop. current queue = " + String(self.queue.count))

        semaphoreDispatchQueue.async {
            print("remained threads - " + String(self.process.count))
            if self.process.count == self.max {
                return
            }
            if let target = self.queue.popLast() {
                remained += 1
                print("Start - " + target)
                self.process.append(target)
                self.taskDispatchQueue.async {
                    defer {
                        remained -= 1
                        self.semaphoreDispatchQueue.async {
                            self.process.removeAllWith(target)
                        }
                        print("Done! current queue = " + String(self.queue.count))
                        self.taskDispatchQueue.async {
                            self.pop()
                        }
                    }
                    
                    guard let handler = FileHandle(forReadingAtPath: target) else { return }
                    
                    guard !self.cancelFlag else { return }
                    
                    var buffer = Data(capacity: 1024 * 1024 * 100)
                    
                    let fileSize = -1
                    
                    let readLength = 1024 * 1024 * 10
                    
                    while true {
                        let tempReadData = handler.availableData
                        buffer.append(tempReadData)
                        if tempReadData.count == 0 {
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
                            guard let cacheURL = self.cacheURL(target) else { return }
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("ZipThumbnail"), object: nil, userInfo: userInfo)
                                do {
                                    try imageBuffer.write(to: cacheURL)
                                } catch {
                                    print(error)
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
    }
}
