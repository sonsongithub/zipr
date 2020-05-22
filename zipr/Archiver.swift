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

class ArchiverTask {
    let progress = Progress()
    let entry: Entry
    let page: Int
    
    init(_ entry: Entry, page: Int) {
        self.entry = entry
        self.page = page
    }
}

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

class Archiver {
    let archive: Archive
    let entries: [Entry]
    let queue: DispatchQueue
    let semaphore = DispatchSemaphore(value: 0)
    let url: URL
    let identifier: String
    
    var reading = false
    
    var taskQueue: [ArchiverTask] = Array([])
    var currentTask: ArchiverTask? = nil
    
    
    init(_ fileURL: URL, identifier: String) throws {
        
        url = fileURL
        self.identifier = identifier
        
        guard let tmp = Archive(url: fileURL, accessMode: .read, preferredEncoding: String.Encoding.shiftJIS) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        archive = tmp
        
        let entryInfos: [EntryInfo] = archive.enumerated()
            .map { (offset, element) -> Entry in
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
            entries = archive.enumerated()
                .sorted(by: { (left, right) -> Bool in
                    return left.element.path < right.element.path
                })
                .map({ (e) -> Entry in
                    return e.element
                })
        } else {
            entries = orderByExtractedIntegerAmongFilePath(entryInfos)
        }
        
        queue = DispatchQueue(label: "archiver")
    }
    
    func cancelAll() {
        for e in taskQueue {
            e.progress.cancel()
        }
    }
    
    func pop() -> Void {
        
        self.semaphore.signal()
        if currentTask != nil {
            self.semaphore.wait()
            return
        }
        guard let tempCurrentTask = taskQueue.popLast() else {
            self.semaphore.wait()
            return
        }
        currentTask = tempCurrentTask
        self.semaphore.wait()

        queue.async {
            do {
                var d = Data()
                
                _ = try self.archive.extract(tempCurrentTask.entry, bufferSize: 20480, skipCRC32: true, progress: tempCurrentTask.progress, consumer: { (data) in
                    d.append(data)
                })
                
                if let image = UIImage(data: d) {
                    
                    let userInfo: [String: Any] = [
                        "image": image,
                        "page": tempCurrentTask.page,
                        "identifier": self.identifier
                    ]
                    
                    NotificationCenter.default.post(name: Notification.Name("Loaded"), object: nil, userInfo: userInfo)
                }
                
            } catch {
                print("error")
            }
            
            self.semaphore.signal()
            self.currentTask = nil
            self.semaphore.wait()
                
            self.pop()
        }
    }
    
    func read(at index: Int) -> Void {
        // ill index for entries
        guard index >= 0 && index < entries.count else {
            return
        }
        
        let entry = entries[index]
        
        let task = ArchiverTask(entry, page: index)
        taskQueue.append(task)
        
        pop()
    }
}
