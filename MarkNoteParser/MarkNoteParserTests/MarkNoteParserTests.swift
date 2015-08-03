/**
* MarknoteParser- a markdown parser
* Copyright (c) 2015, MarkNote. (MIT Licensed)
* https://github.com/marknote/MarknoteParser
*/

import UIKit
import XCTest
import MarkNoteParser

class MarkNoteParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func markdown(input :String)->String{
        let result = MarkNoteParser.toHtml(input)
        println("input: \(input) result:\(result)")
        return result
    }
    
    /*func assertHtmlEauql(expected:String, actual:String){
        return assertHtmlEauql(expected, actual,"")
    }*/
    
    func assertHtmlEauql(expected:String, _ actual:String, _ message:String = ""){
        return XCTAssertEqual(expected.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil),
            actual.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil),
            message)
    }
    
    func testHeading() {
        assertHtmlEauql("<h1>Hello</h1>", markdown("# Hello"), "H1 Heading Pass")
        assertHtmlEauql("<h2>Hello</h2>", markdown("## Hello"), "H2 Heading Pass")
        assertHtmlEauql("<h3>Hello</h3>", markdown("### Hello"), "H3 Heading Pass")
        assertHtmlEauql("<h4>Hello</h4>", markdown("#### Hello"), "H4 Heading Pass")
        assertHtmlEauql("<h5>Hello</h5>", markdown("##### Hello"), "H5 Heading Pass")
        assertHtmlEauql("<h6>Hello</h6>", markdown("###### Hello"), "H6 Heading Pass")
    }
    
    
    func testFencedCode() {
        assertHtmlEauql("<pre class=\"prettyprint lang-swift\">println(&quot;Hello&quot;)\n</pre>\n", markdown("```swift\nprintln(\"Hello\")\n```"), "Fenced Code Pass")
    }
    
    func testDefLinks() {
        assertHtmlEauql("<p><a href=\"www.google.com\">Title</a><br/><br/></p>", markdown("[Title][Google]\n [Google]:www.google.com\n"), "Deflink no title Pass")
        assertHtmlEauql("<p><a href=\"www.google.com\" title=\"GoogleSearch\">text</a><br/><br/></p>", markdown("[text][Google]\n[Google]:www.google.com \"GoogleSearch\"\n"), "Deflink no title Pass")
    }
    
    func testDefImages() {
        assertHtmlEauql("<p><img src=\"aaa\" alt=\"Title\"/><br/><br/></p>", markdown("![Title][image]\n [image]:aaa\n"), "Deflink no title Pass")
        assertHtmlEauql("<p><img src=\"aaa\" alt=\"text\" title=\"TTTT\"/><br/><br/></p>", markdown("![text][image]\n[image]:aaa \"TTTT\"\n"), "Deflink no title Pass")
    }
    
    func testInlineLinks() {
        assertHtmlEauql("<p><a href=\"www.google.com\">Google</a></p>\n", markdown("[Google](www.google.com)"), "inline link Pass")
        assertHtmlEauql("<p><a href=\"www.google.com\" title=\"googlehome\">Google</a></p>\n", markdown("[Google](www.google.com \"googlehome\")"), "inline link Pass")
        
    }
    
    func testInlineImages() {
        assertHtmlEauql("<p><img src=\"url\" alt=\"abc\" /></p>\n", markdown("![abc](url)"), "inline image Pass")
       
    }
    
    func testInlineImages2() {
        assertHtmlEauql("<p>!<img src=\"url\" alt=\"abc\" /></p>\n", markdown("!![abc](url)"), "inline image Pass")
        
    }
    
    func testHRule() {
        assertHtmlEauql("<hr>\n", markdown("-----"), "HRule dashes Pass")
        assertHtmlEauql("<hr>\n", markdown("***"), "HRule asterisks Pass")
        assertHtmlEauql("<hr>\n", markdown("___"), "HRule underscope Pass")
    }
    
    func testLHeading() {
        assertHtmlEauql("<h1>Hello</h1>\n", markdown("Hello\n====="), "H1 LHeading Pass")
        assertHtmlEauql("<h2>Hello</h2>\n", markdown("Hello\n-----"), "H2 LHeading Pass")
    }
    
    func testBlockQuote() {
        assertHtmlEauql("<blockquote><h3>Hello</h3></blockquote>", markdown(">### Hello"), "HRule dashes Pass")
    }
    
    func testInlineCode() {
        assertHtmlEauql("<p><code>Hello</code></p>\n", markdown("`Hello`\n"), "InlineCode Pass")
    }
    
    func testBlockCode() {
        assertHtmlEauql("<pre class=\"no-highlight\">\nHello\n</pre>\n", markdown("``` \r\nHello\r\n```\n"), "BlockCode Pass")
    }
    
    func testDoubleEmphasis() {
        assertHtmlEauql("<p><strong>Hello</strong></p>\n", markdown("**Hello**"), "Double Emphasis Asterisk Pass")
        assertHtmlEauql("<p><strong>World</strong></p>\n", markdown("__World__"), "Double Emphasis Underscope Pass")
        assertHtmlEauql("<p><del>Hello</del></p>\n", markdown("~~Hello~~"), "Double Emphasis Asterisk Pass")
       
    }
    
    func testDoubleEmphasis2() {
        assertHtmlEauql("<p>123<strong>Hello</strong>456</p>\n", markdown("123**Hello**456"), "Double Emphasis Asterisk Pass")
        assertHtmlEauql("<p>123<strong>World</strong>456</p>\n", markdown("123__World__456"), "Double Emphasis Underscope Pass")
    }

    
    func testEmphasis() {
        assertHtmlEauql("<p><em>Hello</em></p>\n", markdown("*Hello*"), "Emphasis Asterisk Pass")
        assertHtmlEauql("<p><em>World</em></p>\n", markdown("_World_"), "Emphasis Underscope Pass")
        assertHtmlEauql("<p>123<em>Hello</em>456</p>\n", markdown("123*Hello*456"), "Emphasis Asterisk Pass")
        assertHtmlEauql("<p>123<em>World</em>456</p>\n", markdown("123_World_456"), "Emphasis Underscope Pass")
        assertHtmlEauql("<p>123<em>Hello</em>456123<em>world</em>456</p>\n", markdown("123*Hello*456123*world*456"), "Emphasis Asterisk Pass")
        assertHtmlEauql("<p>123<em>World</em>456123<em>world</em>456</p>\n", markdown("123_World_456123*world*456"), "Emphasis Underscope Pass")
    }
    
    func testBulletList()
    {
        let input = "A bulleted list:\n- a\n- b\n- c\n"
        let expected = "<p>A bulleted list:<br/><ul><li>a</li><li>b</li><li>c</li></ul></p>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
    }
    
    
    func testDetectPositions() {
        let expected = [1,2,3]
        let actual = MarkNoteParser.detectPositions(["1","2","3"],inStr:"0123")
        XCTAssertEqual(expected, actual)

    }
    
    func testDetectPositions2() {
        let expected = [2,4,5]
        let actual = MarkNoteParser.detectPositions(["2","4","5"],inStr:"012345")
        XCTAssertEqual(expected, actual)
        
    }
    
    func testHTMLTag(){
        
        let input = "<a name=\"html\"/>"
        let expected = "<a name=\"html\"/>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
    }
    
    func testMixedHTMLTag(){
        
        let input = "<a name=\"html\"/>\n## Inline HTML\nYou can also use raw HTML in your Markdown"
        let expected = "<a name=\"html\"/><h2>Inline HTML</h2><p>You can also use raw HTML in your Markdown</p>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
    }
    
    func testHTMLTag2(){
        
        let input = "111<a href='abc'>123</a>222"
        let expected = "<p>111</p><a href='abc'>123</a><p>222</p>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
    }
    
    func testEmbeddedHTML(){
        let input = "<span style='color:red'>Don't modify this note. Your changes will be overrided.</span>"
        let expected = "<span style='color:red'>Don't modify this note. Your changes will be overrided.</span>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
        
    }
    
    func testHTMLInCode(){
        
        let input = "```\n&lt;html&gt;\n```\n"
        let expected = "<pre class=\"no-highlight\">&lt;html&gt;</pre>"
        let actual = markdown(input).stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        assertHtmlEauql(expected, actual)
    }
    
    func testNewLine(){
        
        let input = "abc  \n123"
        let expected = "<p>abc<br/>123</p>"
        let actual = markdown(input)
        assertHtmlEauql(expected, actual)
    }
    
    func testTable(){
        
        let input = "|a|b|c|\n|------|-----|-----|\n|1|2|3|\n\n\n"
        let expected = "<table><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>1</td><td>2</td><td>3</td></tr></table>"
        let actual = markdown(input)
        assertHtmlEauql(expected, actual)
    }
    
    func testTableWithoutOuterPipe(){
        
        let input = "a|b|c\n------|-----|-----\n1|2|3\n\n\n"
        let expected = "<table><tr><th>a</th><th>b</th><th>c</th></tr><tr><td>1</td><td>2</td><td>3</td></tr></table>"
        let actual = markdown(input)
        assertHtmlEauql(expected, actual)
    }
    
    func testTableWithColumnAignment(){
        
        let input = "a|b|c\n------|:-----:|-----:\n1|2|3\n\n\n"
        let expected = "<table><tr><th>a</th><th style=\"text-align: center;\">b</th><th style=\"text-align: right;\">c</th></tr><tr><td>1</td><td style=\"text-align: center;\">2</td><td style=\"text-align: right;\">3</td></tr></table>"
        let actual = markdown(input)
        assertHtmlEauql(expected, actual)
    }

    
    func testSplitEmptyLiens(){
        XCTAssertEqual(["1","","3"],"1\n\n3".componentsSeparatedByString("\n"))
        XCTAssertEqual(["A bulleted list:","- a","- b","- c",""],"A bulleted list:\n- a\n- b\n- c\n".componentsSeparatedByString("\n"))

    }
}
