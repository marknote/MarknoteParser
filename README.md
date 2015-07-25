# MarkNote Parser

A high performance markdown parser implemented in Swift.

## Purpose

Currently my app [MarkNote](https://itunes.apple.com/us/app/marknote/id991297585?ls=1&mt=8) is using [marked](https://github.com/chjj/marked) to render markdown as HTML.   
After trying to find a relevant markdown parser in Swfit/Object-c while no result, I decided to build my own.


## Usage

Use the method MarkNoteParser.toHtml to convert markdown text to HTML string, like this:

```
func markdown(input :String)->String{
        let result = MarkNoteParser.toHtml(input)
        println("input: \(input) result:\(result)")
        return result
    }
```


## Status

This parser is in a very early stage yet, and only have some very basic markdown features yet.    
I am still heavily working on it.

### Features has implemented

The following test cases have been passed:
```
func testHeading() {
        XCTAssertEqual("<h1>Hello</h1>", markdown("# Hello"), "H1 Heading Pass")
        XCTAssertEqual("<h2>Hello</h2>", markdown("## Hello"), "H2 Heading Pass")
        XCTAssertEqual("<h3>Hello</h3>", markdown("### Hello"), "H3 Heading Pass")
        XCTAssertEqual("<h4>Hello</h4>", markdown("#### Hello"), "H4 Heading Pass")
        XCTAssertEqual("<h5>Hello</h5>", markdown("##### Hello"), "H5 Heading Pass")
        XCTAssertEqual("<h6>Hello</h6>", markdown("###### Hello"), "H6 Heading Pass")
    }
    
    func testBlockQuote() {
        XCTAssertEqual("<blockquote><h3>Hello</h3></blockquote>", markdown(">### Hello"), "HRule dashes Pass")
    }
    
    func testInlineCode() {
        XCTAssertEqual("<code>Hello</code>", markdown("`Hello`\n"), "InlineCode Pass")
    }
    
    func testBlockCode() {
        XCTAssertEqual("<code>Hello</code>", markdown("``` \r\nHello\r\n```\n"), "BlockCode Pass")
    }
    
    func testDoubleEmphasis() {
        XCTAssertEqual("<strong>Hello</strong>", markdown("**Hello**"), "Double Emphasis Asterisk Pass")
        XCTAssertEqual("<strong>World</strong>", markdown("__World__"), "Double Emphasis Underscope Pass")
    }
    
    func testEmphasis() {
        XCTAssertEqual("<em>Hello</em>", markdown("*Hello*"), "Emphasis Asterisk Pass")
        XCTAssertEqual("<em>World</em>", markdown("_World_"), "Emphasis Underscope Pass")
    } 
```
    




If you have any suggestion or feedback, feel free to drop me a message or follow me on [twitter @markmarknote](https://twitter.com/markmarknote)