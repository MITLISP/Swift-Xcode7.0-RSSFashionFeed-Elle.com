//
//  FeedHelper.swift
//  RSS
//
//  Created by Christopher Ching on 2014-11-28.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

import UIKit

class FeedHelper: NSObject, NSXMLParserDelegate {
    
    var articles:[Article] = [Article]()

   
    // Parser vars
    var currentElement:String = ""
    var foundCharacters:String = ""
    var attributes:[NSObject:AnyObject]?
    var currentlyConstructingArticle:Article = Article()
    
    override init() {
        
        super.init()
    }
    
    func startParsing(feedUrl:NSURL) {
 
        let feedParser:NSXMLParser? = NSXMLParser(contentsOfURL: feedUrl)
        
        if let actualFeedParser = feedParser {
            
            // Download feed and parse out articles
            actualFeedParser.delegate = self
            actualFeedParser.parse()
        }

    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {

        if elementName == "item" ||
            elementName == "title" ||
            elementName == "description" ||
            elementName == "link" {
                
                self.currentElement = elementName
                self.attributes = attributeDict
        }
        
        if elementName == "item" {
            
            // Start new article
            self.currentlyConstructingArticle = Article()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if self.currentElement == "item" ||
            self.currentElement == "title" ||
            self.currentElement == "description" ||
            self.currentElement == "link" {
                
                self.foundCharacters += string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title" {
            
            // Parsing of the title element is complete, save the data into the article obj
            let title:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentlyConstructingArticle.articleTitle = title
        }
        else if elementName == "description" {
            
            // Parsing of the content element is complete, save the data into the article obj
            self.currentlyConstructingArticle.articleDesc = foundCharacters
            
            // Extract out article image from the content and save it to the articleImageUrl property of the article obj
            
            // Search for http
            if let startRange = foundCharacters.rangeOfString("http://ell.h-cdn.co", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) {
                
                // If found, search for .jpg
                if let endRange = foundCharacters.rangeOfString(".jpg", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) {
                    
                    // Take the substring out from startrange to endrange
                    let imgString:String = foundCharacters.substringWithRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex))
                    
                    // Assign to article property
                    self.currentlyConstructingArticle.articleImageUrl = imgString
                }
                    
                    // If .jpg not found, the search for .png
                else if let endRange = foundCharacters.rangeOfString(".png", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) {
                    
                    // Take the substring out from startrange to endrange
                    let imgString:String = foundCharacters.substringWithRange(Range<String.Index>(start: startRange.startIndex, end: endRange.endIndex))
                    
                    // Assign to article property
                    self.currentlyConstructingArticle.articleImageUrl = imgString
                }
            }
        }

            
            
        else if elementName == "link" {
            
            // Parsing of the link element is complete, save the data into the article obj
            let link:String = foundCharacters.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.currentlyConstructingArticle.articleLink = link
        }
            
        else if elementName == "item" {
                
            // Parsing of an entry element is complete, append the article obj to our array and start a new article obj
            self.articles.append(self.currentlyConstructingArticle)
        }
            
        // Reset found characters
        self.foundCharacters = ""
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        
        // Use notification center to notify FeedModel
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName("feedHelperFinished", object: self)
        
    }
    
    
}
