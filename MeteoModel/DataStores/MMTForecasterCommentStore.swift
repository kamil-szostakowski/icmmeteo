//
//  MMTCommentStore.swift
//  MobileMeteo
//
//  Created by szostakowskik on 20.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public struct MMTForecasterCommentStore
{
    // MARK: Initializers
    public init() {}
    
    // MARK: Interface methods
    public func forecasterComment(completion: @escaping MMTFetchCommentCompletion)
    {
        let baseUrl = try? URL.mmt_meteorogramDownloadBaseUrl(for: .UM)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: baseUrl)
        
        session.html(from: URL.mmt_forecasterCommentUrl(), encoding: .isoLatin2) {
            (html: String?, error: MMTError?) in
            
            guard let htmlString = html, error == nil else {
                completion(nil, .commentFetchFailure)
                return
            }
            
            guard let comment = self.comment(from: htmlString) else {
                completion(nil, .commentFetchFailure)
                return
            }
            
            guard let formattedComment = try? NSAttributedString(htmlString: comment) else {
                completion(nil, .commentFetchFailure)
                return
            }
            
            completion(formattedComment, nil)
        }
    }
    
    // MARK: Helper methods
    private func comment(from html: String) -> String?
    {
        let pattern = "(<div style=\"padding.*</div>)"
        let range = NSMakeRange(0, html.lengthOfBytes(using: .windowsCP1250))
        
        let regexp = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
        let hits = regexp.matches(in: html, options: NSRegularExpression.MatchingOptions(), range: range)
        
        guard let match = hits.first else {
            return nil
        }

        return (html as NSString).substring(with: match.range)
    }
}

extension NSAttributedString
{
    convenience init(htmlString html: String) throws
    {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
    }
    
}
