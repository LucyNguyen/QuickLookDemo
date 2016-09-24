//
//  FileListViewController.swift
//  QuickLookDemo
//
//  Created by Gabriel Theodoropoulos on 3/28/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit
import QuickLook

class FileListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblFileList: UITableView!
    let fileNames = ["SycamoreTree_Keynote.key", "SycamoreTree_Pages.pages", "SycamoreTree_Pdf.pdf", "SycamoreTree_Text.txt", "SycamoreTree_Image.jpg"]
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        navigationItem.title = "Quick Look Demo"
        
        createFileURLs()
        quickLookController.dataSource = self
        quickLookController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Custom Methods
    
    func configureTableView() {
        tblFileList.delegate = self
        tblFileList.dataSource = self
        tblFileList.registerNib(UINib(nibName: "FileListCell", bundle: nil), forCellReuseIdentifier: "idCellFile")
        tblFileList.reloadData()
    }
    
    func createFileURLs() {
        for file in fileNames {
            let fileParts = file.componentsSeparatedByString(".")
            guard let fileURL = NSBundle.mainBundle().URLForResource(fileParts[0], withExtension: fileParts[1]) else {
                continue
            }
            
            if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
                fileURLs.append(fileURL)
            }
        }
    }
    
    func extractFilename(fileURL: NSURL) -> (fileName: String, fileExtension: String) {
        let fileURLParts = fileURL.path!.componentsSeparatedByString("/")
        let fileName = fileURLParts.last
        let filenameParts = fileName?.componentsSeparatedByString(".")
        
        // Return file name and file extension
        return (filenameParts![0], filenameParts![1])
    }

    func getFileTypeFromFileExtension(fileExtension: String) -> String {
        var fileType = ""
        
        switch fileExtension {
        case "docx":
            fileType = "Microsoft Word document"
            
        case "pages":
            fileType = "Pages document"
            
        case "jpeg":
            fileType = "Image document"
            
        case "key":
            fileType = "Keynote document"
            
        case "pdf":
            fileType = "PDF document"
            
            
        default:
            fileType = "Text document"
            
        }
        
        return fileType
    }
    
    // MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileURLs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellFile", forIndexPath: indexPath)
        
        let currentFileParts = extractFilename(fileURLs[indexPath.row])
        
        cell.textLabel?.text = currentFileParts.fileName
        cell.detailTextLabel?.text = getFileTypeFromFileExtension(currentFileParts.fileExtension)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if QLPreviewController.canPreviewItem(fileURLs[indexPath.row]) {
            quickLookController.currentPreviewItemIndex = indexPath.row
            navigationController?.pushViewController(quickLookController, animated: true)
        }    
    }
}

extension FileListViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
}

extension FileListViewController: QLPreviewControllerDelegate {
    func previewControllerWillDismiss(controller: QLPreviewController) {
        print("The Preview Controller will be dismissed")
    }
    
    func previewControllerDidDismiss(controller: QLPreviewController) {
        tblFileList.deselectRowAtIndexPath(tblFileList.indexPathForSelectedRow!, animated: true)
        print("The Preview Controller has been dismissed.")
    }
    
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        if item as! NSURL == fileURLs[0] {
            return true
        }
        else {
            print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
}
