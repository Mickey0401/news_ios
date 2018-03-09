//
//  OfflineFileManager.swift
//  havr
//
//  Created by Personal on 5/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class OfflineFileManager: NSObject {
    
    fileprivate static var fileManager : FileManager {
        return FileManager.default
    }
    
    fileprivate static var documentsURL: URL {
        return try! OfflineFileManager.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    static func getResourceUrl(with name: String) -> URL {
        let documentDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentDirectoryURL.appendingPathComponent(name)
    }
    
    @discardableResult
    static func store(object data: Data, at url: URL) -> Bool {
        do {
            try data.write(to: url, options: .atomic)
            
            print("Data stored in local at: \(url.absoluteString)")
            
            return true
        }
        catch {
            return false
        }
    }
    
    @discardableResult
    static func remove(with url: URL) -> Bool {
        
        do {
            try fileManager.removeItem(at: url)
            print("Deleted item at: \(url.absoluteString)")
            return true
        } catch {
            print("Deleted item failed at: \(url.absoluteString)")
            return false
        }
    }
    
    static func getResourceData(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        }
        catch {
            return nil
        }
    }
    
    static func deleteAll() {
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: OfflineFileManager.documentsURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
            }
            
            print("Document directory is cleared.")
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
