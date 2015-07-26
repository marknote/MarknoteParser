

import Foundation

extension String {
    
    //MARK: Helper methods
    
    /**
    Returns the length of the string.
    
    :returns: Int length of the string.
    */
    
    var length: Int {
        return count(self)
    }
    
    var objcLength: Int {
        return count(self.utf16)
    }
    
    //MARK: - Linguistics
    
    /**
    Returns the langauge of a String
    
    NOTE: String has to be at least 4 characters, otherwise the method will return nil.
    
    :returns: String! Returns a string representing the langague of the string (e.g. en, fr, or und for undefined).
    */
    func detectLanguage() -> String? {
        if self.length > 4 {
            let tagger = NSLinguisticTagger(tagSchemes:[NSLinguisticTagSchemeLanguage], options: 0)
            tagger.string = self
            return tagger.tagAtIndex(0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
        }
        return nil
    }
    
    /**
    Returns the script of a String
    
    :returns: String! returns a string representing the script of the String (e.g. Latn, Hans).
    */
    func detectScript() -> String? {
        if self.length > 1 {
            let tagger = NSLinguisticTagger(tagSchemes:[NSLinguisticTagSchemeScript], options: 0)
            tagger.string = self
            return tagger.tagAtIndex(0, scheme: NSLinguisticTagSchemeScript, tokenRange: nil, sentenceRange: nil)
        }
        return nil
    }
    
    /**
    Check the text direction of a given String.
    
    NOTE: String has to be at least 4 characters, otherwise the method will return false.
    
    :returns: Bool The Bool will return true if the string was writting in a right to left langague (e.g. Arabic, Hebrew)
    
    */
    var isRightToLeft : Bool {
        let language = self.detectLanguage()
        return (language == "ar" || language == "he")
    }
    
    
    //MARK: - Usablity & Social
    
    /**
    Check that a String is only made of white spaces, and new line characters.
    
    :returns: Bool
    */
    func isOnlyEmptySpacesAndNewLineCharacters() -> Bool {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).length == 0
    }
    
    /**
    Checks if a string is an email address using NSDataDetector.
    
    :returns: Bool
    */
    var isEmail: Bool {
        let dataDetector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil)
        let firstMatch = dataDetector?.firstMatchInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length))
        
        return (firstMatch?.range.location != NSNotFound && firstMatch?.URL?.scheme == "mailto")
    }
    
    /**
    Check that a String is 'tweetable' can be used in a tweet.
    
    :returns: Bool
    */
    func isTweetable() -> Bool {
        let tweetLength = 140,
        // Each link takes 23 characters in a tweet (assuming all links are https).
        linksLength = self.getLinks().count * 23,
        remaining = tweetLength - linksLength
        
        if linksLength != 0 {
            return remaining < 0
        } else {
            return !(count(self.utf16) > tweetLength || count(self.utf16) == 0 || self.isOnlyEmptySpacesAndNewLineCharacters())
        }
    }
    
    /**
    Gets an array of Strings for all links found in a String
    
    :returns: [String]
    */
    func getLinks() -> [String] {
        let detector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil)
        
        let links = detector?.matchesInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length)).map {$0 as! NSTextCheckingResult}
        
        return links!.filter { link in
            return link.URL != nil
            }.map { link -> String in
                return link.URL!.absoluteString!
        }
    }
    
    /**
    Gets an array of URLs for all links found in a String
    
    :returns: [NSURL]
    */
    func getURLs() -> [NSURL] {
        let detector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil)
        
        let links = detector?.matchesInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length)).map {$0 as! NSTextCheckingResult}
        
        return links!.filter { link in
            return link.URL != nil
            }.map { link -> NSURL in
                return link.URL!
        }
    }
    
    
    /**
    Gets an array of dates for all dates found in a String
    
    :returns: [NSDate]
    */
    func getDates() -> [NSDate] {
        let error: NSErrorPointer = NSErrorPointer()
        let detector = NSDataDetector(types: NSTextCheckingType.Date.rawValue, error: error)
        let dates = detector?.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, count(self.utf16))) .map {$0 as! NSTextCheckingResult}
        
        return dates!.filter { date in
            return date.date != nil
            }.map { link -> NSDate in
                return link.date!
        }
    }
    
    /**
    Gets an array of strings (hashtags #acme) for all links found in a String
    
    :returns: [String]
    */
    func getHashtags() -> [String]? {
        let hashtagDetector = NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let results = hashtagDetector?.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, count(self.utf16))).map { $0 as! NSTextCheckingResult }
        
        return results?.map({
            (self as NSString).substringWithRange($0.rangeAtIndex(1))
        })
    }
    
    /**
    Gets an array of distinct strings (hashtags #acme) for all hashtags found in a String
    
    :returns: [String]
    */
    func getUniqueHashtags() -> [String]? {
        return Array(Set(getHashtags()!))
    }
    
    
    
    /**
    Gets an array of strings (mentions @apple) for all mentions found in a String
    
    :returns: [String]
    */
    func getMentions() -> [String]? {
        let hashtagDetector = NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        let results = hashtagDetector?.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, count(self.utf16))).map { $0 as! NSTextCheckingResult }
        
        return results?.map({
            (self as NSString).substringWithRange($0.rangeAtIndex(1))
        })
    }
    
    /**
    Check if a String contains a Date in it.
    
    :returns: Bool with true value if it does
    */
    func getUniqueMentions() -> [String]? {
        return Array(Set(getMentions()!))
    }
    
    
    /**
    Check if a String contains a link in it.
    
    :returns: Bool with true value if it does
    */
    func containsLink() -> Bool {
        return self.getLinks().count > 0
    }
    
    /**
    Check if a String contains a date in it.
    
    :returns: Bool with true value if it does
    */
    func containsDate() -> Bool {
        return self.getDates().count > 0
    }
    
    /**
    :returns: Base64 encoded string
    */
    func encodeToBase64Encoding() -> String {
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        return utf8str.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
    
    /**
    :returns: Decoded Base64 string
    */
    func decodeFromBase64Encoding() -> String {
        /*let base64data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        return NSString(data: base64data!, encoding: NSUTF8StringEncoding)! as String*/
        /*let base64Decoded = NSData(base64EncodedString: self, options:   NSDataBase64DecodingOptions(rawValue: 0))
        .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
        return base64Decoded as! String*/
        
        let decodedData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        return NSString(data: decodedData!, encoding: NSUTF8StringEncoding)! as String
        
    }
    
    func contains (substring:String)->Bool{
        return self.rangeOfString(substring) != nil
    }
    
    
    
    // MARK: Subscript Methods
    
    /*subscript (i: Int) -> String {
        //return String(Array(self)[i])
        return self[advance(self.startIndex, i)]
    }*/
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    
    
    
    subscript (range: NSRange) -> String {
        let end = range.location + range.length
        return self[Range(start: range.location, end: end)]
    }
    
    subscript (substring: String) -> Range<String.Index>? {
        return rangeOfString(substring, options: NSStringCompareOptions.LiteralSearch, range: Range(start: startIndex, end: endIndex), locale: NSLocale.currentLocale())
    }
    
    func substring(begin:Int, end:Int)->String{
        let range:NSRange = NSMakeRange(begin, end - begin + 1 )
        return self[range]
    }
    
    
    func stringByDecodingURLFormat() ->String {
        return self.stringByReplacingOccurrencesOfString("+", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func trim() ->String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

    }
    
    func indexOf(toFind:String)->Int{
        
        if let range = self.rangeOfString(toFind){
            
            return  distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func contains3PlusandOnlyChars( char:String)-> Bool{
        return self.length >= 3
            && self.indexOf(char) == 0
            && self.stringByReplacingOccurrencesOfString(char, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).length == 0
    }
    
    func replaceAll(target:String, toStr: String)->String{
        return self.stringByReplacingOccurrencesOfString(target, withString: toStr, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}