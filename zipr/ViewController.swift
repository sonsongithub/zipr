//
//  ViewController.swift
//  zippy
//
//  Created by sonson on 2020/05/03.
//  Copyright © 2020 sonson. All rights reserved.
//

import UIKit
import ZIPFoundation

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet var leftImageView: UIImageView? = nil
    @IBOutlet var rightImageView: UIImageView? = nil
    @IBOutlet var indicator: UIActivityIndicatorView? = nil
    
    var currentLeftPage: Int = 0
    
    var archiver: Archiver?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                currentLeftPage += 2
                archiver?.read(at: currentLeftPage)
                archiver?.read(at: currentLeftPage + 1)
                didHandleEvent = true
            }
            if key.keyCode == .keyboardSpacebar {
                currentLeftPage += 2
                archiver?.read(at: currentLeftPage)
                archiver?.read(at: currentLeftPage + 1)
                didHandleEvent = true
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                currentLeftPage += 1
                archiver?.read(at: currentLeftPage)
                archiver?.read(at: currentLeftPage + 1)
                didHandleEvent = true
            }
            if key.characters == "o" {
                if let archiver = archiver {
                    archiver.cancelAll()
                }
                
                openPicker()
                didHandleEvent = true
            }
        }
        
        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let archiver = archiver {
            archiver.cancelAll()
        }
        let activity = NSUserActivity(activityType: "ok")
        activity.persistentIdentifier = NSUUID().uuidString
        self.userActivity = activity
        
        
        openPicker()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.view.window?.windowScene?.userActivity = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: Notification.Name("Loaded"), object: nil)
    }
    
    @objc func handle(notification : Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let image = userInfo["image"] as? UIImage else {
            return
        }
        
        guard let page = userInfo["page"] as? Int else {
            return
        }
        
        guard let sent_identifier = userInfo["identifier"] as? String else {
            return
        }
        
        DispatchQueue.main.async {
            guard let identifider = self.userActivity?.persistentIdentifier else {
                return
            }
            if sent_identifier == identifider {
                if self.currentLeftPage == page {
                    self.rightImageView?.image = image
                } else if self.currentLeftPage + 1 == page {
                    self.leftImageView?.image = image
                }
            }
        }
        
    }
    
    func openPicker() {
        self.indicator?.isHidden = false
        self.indicator?.startAnimating()

        DispatchQueue.main.async {
            let picker = UIDocumentPickerViewController.init(documentTypes: ["public.zip-archive"], in: .import)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.indicator?.stopAnimating()
        self.indicator?.isHidden = true
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        
        guard let identifider = self.userActivity?.persistentIdentifier else {
            return
        }
        
        if let url = urls.first {
            DispatchQueue.main.async {
                do {
                    let tmp = try Archiver(url, identifier: identifider)
                    self.currentLeftPage = 0
                    self.archiver = tmp
                    self.archiver?.read(at: self.currentLeftPage)
                    self.archiver?.read(at: self.currentLeftPage + 1)
                    
                    let userActivity = NSUserActivity(activityType: "reader")
                    userActivity.title = "Restore Item"
                    
                    let state: [String: URL] = ["URL": tmp.url]
                    userActivity.addUserInfoEntries(from: state)
                    
                    self.view.window?.windowScene?.userActivity = userActivity
                    
                } catch let error as NSError {
                    print(error)
                } catch {
                    print("unknown error")
                }
                DispatchQueue.main.async {
                    self.indicator?.stopAnimating()
                    self.indicator?.isHidden = true
                }
            }
        } else {
            self.indicator?.stopAnimating()
            self.indicator?.isHidden = true
        }
        
    }
    
    @IBAction func didPressAttachment(_ sender: UIButton) {
        
        if let archiver = archiver {
            archiver.cancelAll()
        }
        
        openPicker()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(self.traitCollection)
    }


    // Required if you want to use UIKeyCommands (up and down arrows) to work for iOS.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // The responder chain is asking us which commands you support.
    // Enable/disable certain Edit menu commands.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(newAction(_:)) {
            // User wants to perform a "New" operation.
            return true
        }
        if action == #selector(newAction2(_:)) {
            // User wants to perform a "New" operation.
            return true
        }
        return false
    }
    
    @objc
    // User chose "New" sub menu command from the File menu (New Date or Text item).
    func newAction(_ sender: UICommand) {
        openPicker()
    }
    @objc
    // User chose "New" sub menu command from the File menu (New Date or Text item).
    func newAction2(_ sender: UICommand) {
        let userActivity = NSUserActivity(
          activityType: "com.sonson.multiwindow"
        )
        
//        let conf = UISceneConfiguration(
//          name: "Default Configuration",
//          sessionRole: .windowApplication
//        )
        
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
}

extension ViewController {
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
         super.restoreUserActivityState(activity)
    }

}


// MARK: - State Restoration (UIStateRestoring)

extension ViewController {
    
/// - Tag: encodeRestorableState
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        let userActivity = NSUserActivity(activityType: "reader")
        userActivity.title = "Restore Item"
        
        if let archiver = archiver {
            let state: [String: URL] = ["URL": archiver.url]
            userActivity.addUserInfoEntries(from: state)
        }
        
        
//
//        let encodedActivity = NSUserActivityEncoder(detailUserActivity)
//        coder.encode(encodedActivity, forKey: DetailViewController.restoreActivityKey)
    }
   
/// - Tag: decodeRestorableState
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
}
