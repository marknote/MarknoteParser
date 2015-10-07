# MarkNote Parser 


Objective-C version: https://github.com/marknote/MarkNoteParserObjC
Swift version: https://github.com/marknote/MarknoteParser


A dead simple markdown parser implemented in both **Swift** and **Objective-C** with performance in mind, which can help you to transform markdown code into HTML.    
Most of markdown parsers highly depend on regular expression while MarkNote Parser avoids doing so.

## Purpose

At the beginning my app [MarkNote](https://itunes.apple.com/us/app/marknote/id991297585?ls=1&mt=8) was using [marked](https://github.com/chjj/marked) to render markdown as HTML.   
After trying to find a relevant markdown parser in Swfit/Object-c while no luck, I decided to build my own.


## Usage

### Using swift version
- Cope 2 files into your project:  
-- **StringExtensions.swift** , extension of String class;  
-- **MarkNoteParser.swift**, the parser class;  

- Use the method MarkNoteParser.toHtml to convert markdown text to HTML string, like this:

```swift
func markdown(input :String)->String{
        let result = MarkNoteParser.toHtml(input)
        println("input: \(input) result:\(result)")
        return result
    }
```
### Using objetive-c version
- Cope all files under "MarkNoteParserOC" folder into your project, and import the header file like this

```objective-c
#import "MarkNoteParser.h"
```
- Then you can call MarkNoteParser to parse your markdown document:

```objective-c
NSString* result = [MarkNoteParser toHtml:input];
return result;
```

## Features 

### headers

```markdown
# H1
## H2
### H3
```
will be transformed into:

```html
<h1>H1</h1><h2>H2</h2><h3>H3</h3>
```

### Emphasis

```markdown
Emphasis, aka italics, with *asterisks* or _underscores_.
Strong emphasis, aka bold, with **asterisks** or __underscores__.
Strikethrough uses two tildes. ~~Scratch this.~~
```
will be transformed into:

```html
<p>Emphasis, aka italics, with <em>asterisks</em> or <em>underscores</em>.<br/></p>
<p>Strong emphasis, aka bold, with <strong>asterisks</strong> or <strong>underscores</strong>.<br/></p>
<p>Strikethrough uses two tildes. <u>Scratch this.</u><br/></p>
```

### Links

```markdown
[I'm an inline-style link](https://www.google.com)
[I'm an inline-style link with title](https://www.google.com "Google's Homepage")
``` 

will be transformed into:

```html
<p><a href="https://www.google.com">I'm an inline-style link</a><br/></p>
<p><a href="https://www.google.com" title="Google's Homepage">I'm an inline-style link with title</a><br/></p>
```
### Images

```markdown
![alt text](https://avatars3.githubusercontent.com/u/12975088?v=3&s=40 "Logo Title")
```
will be transformed into:
```html
<img src="https://avatars3.githubusercontent.com/u/12975088?v=3&s=40" title="Logo Title" alt="alt text" />
```
### Code 

<pre class="lang-markdown">
```
var s = "JavaScript syntax highlighting";
alert(s);
```
</pre>

will be transformed into:
```html
<pre class="lang-javascript">
var s = &quot;JavaScript syntax highlighting&quot;;
alert(s);
</pre>
```

### Table

```markdown
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```

will be transformed into:

```html
<table><tr><th> Tables        </th><th> Are           </th><th style="text-align: center;"> Cool </th></tr><tr><td> col 3 is      </td><td> right-aligned </td><td style="text-align: center;"> $1600 </td></tr><tr><td> col 2 is      </td><td> centered      </td><td style="text-align: center;">   $12 </td></tr><tr><td> zebra stripes </td><td> are neat      </td><td style="text-align: center;">    $1 </td></tr></table><p>The outer pipes (|) are optional, and you don&#39;t need to make the raw Markdown line up prettily. You can also use inline Markdown.<br/></p>
```

    
## Feedback 

If you have any suggestion or feedback, feel free to drop me a message or follow me on [twitter @markmarknote](https://twitter.com/markmarknote)