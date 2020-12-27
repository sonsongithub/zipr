//
//  Archiver.swift
//  zippy
//
//  Created by sonson on 2020/05/04.
//  Copyright © 2020 sonson. All rights reserved.
//

import Foundation
import ZIPFoundation
import UIKit
import CommonCrypto

class ArchiverTask {
    let progress = Progress()
    let entry: Entry
    let page: Int
    
    init(_ entry: Entry, page: Int) {
        self.entry = entry
        self.page = page
    }
}

private let __regex: NSRegularExpression! = {
    do {
        return try NSRegularExpression(pattern: "._", options: .caseInsensitive)
    } catch {
        assert(false, "Fatal error: \(#file) \(#line) \(error)")
        return nil
    }
}()

private let extension_regrex: NSRegularExpression! = {
    do {
        return try NSRegularExpression(pattern: "(jpg|gif|png|jpeg)", options: .caseInsensitive)
    } catch {
        assert(false, "Fatal error: \(#file) \(#line) \(error)")
        return nil
    }
}()

private let regex: NSRegularExpression! = {
    do {
        return try NSRegularExpression(pattern: "^[^\\.]+.?\\.(jpg|gif|png|jpeg)", options: .caseInsensitive)
    } catch {
        assert(false, "Fatal error: \(#file) \(#line) \(error)")
        return nil
    }
}()

private let regex_extract_num: NSRegularExpression! = {
    do {
        return try NSRegularExpression(pattern: "(\\d+)", options: .caseInsensitive)
    } catch {
        assert(false, "Fatal error: \(#file) \(#line) \(error)")
        return nil
    }
}()

struct EntryInfo {
    let entry: Entry
    let unescapedFilePath: String
}

struct EntryKeyPair {
    let entry: Entry
    let key: String
}

func extractMaximumIntegerAmongFilePaths(_ entryInfos: [EntryInfo]) -> Int {
    
    let integers = entryInfos.map { (entryInfo) -> [Int] in
        let matches = regex_extract_num.matches(in: entryInfo.unescapedFilePath, range: NSRange(location: 0, length: entryInfo.unescapedFilePath.count))
        let a:[Int] = matches.map { (result) -> String in
            return substring(entryInfo.unescapedFilePath, from: result)
        }
        .compactMap { (string) -> Int? in
            return Int(string)
        }
        
        return a
    }
    
    let a: [Int] = Array(integers.joined())
    
    return a.max() ?? 1
}

func substring(_ string: String, from result: NSTextCheckingResult) -> String {
    let from = string.index(string.startIndex, offsetBy: result.range.location)
    let to = string.index(string.startIndex, offsetBy: result.range.location + result.range.length - 1)
    return String(string[from...to])
}

func extractAllIntegerFromString(_ string: String) -> Int? {
    return nil
}

func orderByExtractedIntegerAmongFilePath(_ entryInfos: [EntryInfo]) -> [Entry] {

    let maximum_integer = extractMaximumIntegerAmongFilePaths(entryInfos)
    
    let digit_count = Int(log10(Double(maximum_integer))) + 2
    
    let format = String(format: "%%0%dd", digit_count)
    
    return entryInfos.map { (entryInfo) -> EntryKeyPair in
        let matches = regex_extract_num.matches(in: entryInfo.unescapedFilePath, range: NSRange(location: 0, length: entryInfo.unescapedFilePath.count))
        
        let key = matches.map { (result) -> String in
            return substring(entryInfo.unescapedFilePath, from: result)
        }
        .compactMap { (string) -> Int? in
            return Int(string)
        }
        .map { (integer) -> String in
            return String(format: format, integer)
        }
        .joined(separator: "_")
        
        return EntryKeyPair(entry: entryInfo.entry, key: key)
    }
    .sorted { (left, right) -> Bool in
        return left.key < right.key
    }
    .map { (pair) -> Entry in
        return pair.entry
    }
}

extension Archive {
    func extractOrderedContents() -> [Entry] {
        
        let entryInfos: [EntryInfo] = self.enumerated()
            .map { (offset, element) -> Entry in
//                print(element.path)
                return element
            }
            .filter { (entry) -> Bool in
                let urlPath = URL(fileURLWithPath: entry.path)
                let matches = regex.matches(in: urlPath.lastPathComponent, range: NSRange(location: 0, length: urlPath.lastPathComponent.count))
                return (matches.count > 0)
            }
            .compactMap { (entry) -> EntryInfo? in
                let urlPath = URL(fileURLWithPath: entry.path)
                if let str = urlPath.lastPathComponent.removingPercentEncoding {
                    return EntryInfo(entry: entry, unescapedFilePath: str)
                }
                return nil
            }
        
        if entryInfos.count == 0 {
            return self.enumerated()
                .filter({ (element) -> Bool in
                    let urlPath = URL(fileURLWithPath: element.element.path)
                    let str = urlPath.pathExtension
                    let result = extension_regrex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
                    return (result.count > 0)
                })
                .filter({ (element) -> Bool in
                    let urlPath = URL(fileURLWithPath: element.element.path)
                    let str = urlPath.lastPathComponent
                    if str.count <= 2 {
                        return false
                    }
                    return !(str[str.startIndex] == "." && str[str.index(str.startIndex, offsetBy: 1)] == "_")
                })
                .sorted(by: { (left, right) -> Bool in
                    return left.element.path < right.element.path
                })
                .map({ (e) -> Entry in
                    return e.element
                })
        } else {
            return orderByExtractedIntegerAmongFilePath(entryInfos)
        }
    }
}

class Archiver {
    let archive: Archive
    let entries: [Entry]
    let queue: DispatchQueue
    let identifier: String
    
    var reading = false
    var useCache = UserDefaults.standard.bool(forKey: "enabled_preference")
    
    let concurrentTestFlag = false
    
    var taskQueue: [ArchiverTask] = Array([])
    var currentTask: ArchiverTask? = nil
    
    static func deleteOldCacheFiles() {
        
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        if let url = urls.first {
            do {
                let paths = try FileManager.default.contentsOfDirectory(atPath: url.path)
                
                let refNow = Date.timeIntervalSinceReferenceDate
                
                paths.forEach { (path) in
                    do {
                        let url = url.appendingPathComponent(path)
                        let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                        if let modificationDate = attr[FileAttributeKey.modificationDate] as? Date {
                            print(modificationDate)
                            if refNow - modificationDate.timeIntervalSinceReferenceDate > 2400 * 24 {
                                try FileManager.default.removeItem(at: url)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    init(data fileData: Data) throws {
        self.identifier = fileData.digest(type: .sha256)
        self.queue = DispatchQueue(label: self.identifier)
        guard let tmp = Archive(data: fileData, accessMode: .read, preferredEncoding: String.Encoding.shiftJIS) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        archive = tmp
        entries = archive.extractOrderedContents()

        NotificationCenter.default.addObserver(self, selector: #selector(didChangeUserDefaults(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func didChangeUserDefaults(notification : Notification) {
        self.useCache = UserDefaults.standard.bool(forKey: "enabled_preference")
    }
    
    init(url fileURL: URL) throws {
        self.identifier = fileURL.absoluteString.digest(type: .sha256)
        queue = DispatchQueue(label: self.identifier)
        
        guard let tmp = Archive(url: fileURL, accessMode: .read, preferredEncoding: String.Encoding.shiftJIS) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        archive = tmp
        entries = archive.extractOrderedContents()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeUserDefaults(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func cancelAll() {
        queue.async {
            for e in self.taskQueue {
                e.progress.cancel()
            }
        }
    }
    
    func cancel(_ page: Int) {
        queue.async {
            self.taskQueue = self.taskQueue.filter({ (task) -> Bool in
                return (page != task.page)
            })
        }
    }
    
    func getCachePath(string: String) throws -> URL {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        if let url = urls.first {
            let directoryURL = url.appendingPathComponent(self.identifier)
            
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) {
                let attr: [FileAttributeKey: Any] = [FileAttributeKey.modificationDate: Date()]
                try FileManager.default.setAttributes(attr, ofItemAtPath: directoryURL.path)
            } else {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            let cacheURL = url.appendingPathComponent(self.identifier).appendingPathComponent(string.digest(type: .sha256))
            return cacheURL
        }
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    func pop() -> Void {
        queue.async {
            if self.currentTask != nil {
                return
            }
            guard let tempCurrentTask = self.taskQueue.popLast() else {
                return
            }
            self.currentTask = tempCurrentTask
            
            do {

                
                #if DEBUG
                if self.concurrentTestFlag {
                    let timeInterval = Double.random(in: 0..<0.6)
                    Thread.sleep(forTimeInterval: timeInterval)
                }
                #endif
                var d = Data()
                
                do {
                    let cacheURL = try self.getCachePath(string: tempCurrentTask.entry.path)
                    if FileManager.default.fileExists(atPath: cacheURL.absoluteString) {
                        d = try Data(contentsOf: cacheURL)
                    }
                } catch {
                    print(error)
                }
                
                if d.count == 0 {
                    _ = try self.archive.extract(tempCurrentTask.entry, bufferSize: 20480, skipCRC32: true, progress: tempCurrentTask.progress, consumer: { (data) in
                        d.append(data)
                    })
                }
                
                if let image = UIImage(data: d) {
                    let userInfo: [String: Any] = [
                        "image": image,
                        "page": tempCurrentTask.page,
                        "identifier": self.identifier
                    ]
                    
                    do {
                        let cacheURL = try self.getCachePath(string: tempCurrentTask.entry.path)
                        if !FileManager.default.fileExists(atPath: cacheURL.absoluteString) {
                            if self.useCache {
                                try d.write(to: cacheURL)
                            }
                        }
                    } catch {
                        print(error)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name("Loaded"), object: nil, userInfo: userInfo)
                } else {
                    print("can not read image")
                    let userInfo: [String: Any] = [
                        "page": tempCurrentTask.page,
                        "identifier": self.identifier
                    ]
                    NotificationCenter.default.post(name: Notification.Name("LoadedFailed"), object: nil, userInfo: userInfo)
                }
                self.currentTask = nil
                
            } catch {
                let userInfo: [String: Any] = [
                    "error": error,
                    "page": tempCurrentTask.page,
                    "identifier": self.identifier
                ]
                NotificationCenter.default.post(name: Notification.Name("LoadedFailed"), object: nil, userInfo: userInfo)
            }
            self.pop()
        }
    }
    
    func cache(at index: Int) -> UIImage? {
        let entry = entries[index]
        do {
            let cacheURL = try self.getCachePath(string: entry.path)
            let data = try Data(contentsOf: cacheURL)
            if let image = UIImage(data: data) {
                return image
            }
            throw NSError(domain: "com.sonson.image", code: 0, userInfo: nil)
        } catch {
            return nil
        }
    }
    
    func push(at index: Int) {
        queue.async {
            if let _ = self.taskQueue.firstIndex(where: { (task) -> Bool in
                return (task.page == index)
            }) {
            } else {
                let entry = self.entries[index]
                let task = ArchiverTask(entry, page: index)
                self.taskQueue.append(task)
            }
            self.pop()
        }
    }
    
    func read(at index: Int, startLoading: Bool = true) -> UIImage? {
        // ill index for entries
        guard index >= 0 && index < entries.count else {
            return nil
        }
        
        if let image = cache(at: index) {
            return image
        }
        
        if startLoading {
            push(at: index)
        }
        
        return nil
    }
}
