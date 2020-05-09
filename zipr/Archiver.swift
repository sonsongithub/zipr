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

class Archiver {
    let archive: Archive
    let entries: [Entry]
    let queue: DispatchQueue
    let semaphore = DispatchSemaphore(value: 0)
    let url: URL
    
    var reading = false
    
    var taskQueue: [ArchiverTask] = Array([])
    var currentTask: ArchiverTask? = nil
    
    init(_ fileURL: URL) throws {
        
        url = fileURL
        
        guard let tmp = Archive(url: fileURL, accessMode: .read) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        guard let regex = try? NSRegularExpression(pattern: "^[^\\.]+.?\\.(jpg|gif|png|jpeg)", options: .caseInsensitive) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        guard let regex2 = try? NSRegularExpression(pattern: "[^\\d]", options: .caseInsensitive) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        func get_file_number(url: URL) -> String {
            let file_name = NSMutableString(string: url.lastPathComponent)
            let length = file_name.lastPathComponent.count
            regex2.replaceMatches(in: file_name, options: .reportProgress, range: NSRange(location: 0, length: length), withTemplate: "")
            return file_name as String
        }
        
        archive = tmp
        entries = archive.enumerated()
            .map { (offset, element) -> Entry in
                print(element.path)
                return element
            }
            .filter({ (e) -> Bool in
                let urlPath = URL(fileURLWithPath: e.path)
                let length = urlPath.lastPathComponent.count
                let matches = regex.matches(in: urlPath.lastPathComponent, range: NSRange(location: 0, length: length))
                return (matches.count > 0)
            })
            .sorted(by: { (lhs, rhs) -> Bool in
                let lhs_file = get_file_number(url: URL(fileURLWithPath: lhs.path))
                let rhs_file = get_file_number(url: URL(fileURLWithPath: rhs.path))
                
                let lhs_int = Int(lhs_file) ?? 0
                let rhs_int = Int(rhs_file) ?? 0
                
                print(lhs_file)
                print(lhs_int)
                
                return (lhs_int < rhs_int)
            })
        
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
                
                print(d.count)
                
                guard let image = UIImage(data: d) else {
                    return
                }
                
                let userInfo: [String: Any] = [
                    "image": image,
                    "page": tempCurrentTask.page
                ]
                
                NotificationCenter.default.post(name: Notification.Name("Loaded"), object: nil, userInfo: userInfo)
                
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
