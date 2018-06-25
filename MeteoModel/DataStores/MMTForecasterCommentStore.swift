//
//  MMTCommentStore.swift
//  MobileMeteo
//
//  Created by szostakowskik on 20.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTForecasterCommentDataStore
{
    func forecasterComment(completion: @escaping (MMTResult<NSAttributedString>) -> Void)
}

public struct MMTForecasterCommentStore: MMTForecasterCommentDataStore
{
    // MARK: Initializers
    public init() {}
    
    // MARK: Interface methods
    public func forecasterComment(completion: @escaping (MMTResult<NSAttributedString>) -> Void)
    {
        let baseUrl = try? URL.mmt_meteorogramDownloadBaseUrl(for: .UM)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: baseUrl)
        
        session.html(from: URL.mmt_forecasterCommentUrl(), encoding: .isoLatin2) {
            (result: MMTResult<String>) in
            
            let reportError = { completion(.failure(.commentFetchFailure)) }
            
            guard case let .success(html) = result else {
                reportError()
                return
            }
            
            guard let comment = self.comment(from: html) else {
                reportError()
                return
            }
            
            guard let formattedComment = try? NSAttributedString(htmlString: comment) else {
                reportError()
                return
            }
            
            completion(.success(formattedComment))
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
