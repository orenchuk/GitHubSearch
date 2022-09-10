//
//  APIKeys.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 07.09.2022.
//

import Foundation

enum APIKeys {
    
    enum GitHub {
        static var clientID: String { value(for: "GITHUB_CLIENT_ID") }
        static var clientSecret: String { value(for: "GITHUB_CLIENT_SECRET") }
    }
    
}

private extension APIKeys {
    
    static var plist: NSDictionary {
        guard let filePath = Bundle.main.path(forResource: "APIKeys-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'APIKeys-Info.plist'.")
        }
        
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't cast to NSDictionary, filepath: \(filePath)")
        }
        
        return plist
    }
    
    static func value(for key: String) -> String {
        guard let value = plist.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'APIKeys-Info.plist'.")
        }
        
        guard !value.starts(with: "_") else {
            fatalError("Property value is empty")
        }
        
        return value
    }
    
}
