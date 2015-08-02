# MarkNote Parser

A dead simple markdown parser implemented in Swift with performance in mind.
Most of markdown parsers highly depend on regular expression while MarkNote Parser avoids doing so.

## Purpose

Currently my app [MarkNote](https://itunes.apple.com/us/app/marknote/id991297585?ls=1&mt=8) is using [marked](https://github.com/chjj/marked) to render markdown as HTML.   
After trying to find a relevant markdown parser in Swfit/Object-c while no result, I decided to build my own.


## Usage

Use the method MarkNoteParser.toHtml to convert markdown text to HTML string, like this:

```swift
func markdown(input :String)->String{
        let result = MarkNoteParser.toHtml(input)
        println("input: \(input) result:\(result)")
        return result
    }
```




## Features 

### headers


```
# H1
## H2
### H3
#### H4
##### H5
###### H6

Alternatively, for H1 and H2, an underline-ish style:

Alt-H1
======

Alt-H2
------
```
will be transformed into:
```
<h1>H1</h1><h2>H2</h2><h3>H3</h3><h4>H4</h4><h5>H5</h5><h6>H6</h6><p>Alternatively, for H1 and H2, an underline-ish style:<br/></p>
<h1>Alt-H1</h1>
<h2>Alt-H2</h2>
```

### Emphasis

```
Emphasis, aka italics, with *asterisks* or _underscores_.
Strong emphasis, aka bold, with **asterisks** or __underscores__.
Strikethrough uses two tildes. ~~Scratch this.~~
```
will be transformed into:
```
<p>Emphasis, aka italics, with <em>asterisks</em> or <em>underscores</em>.<br/></p>
<p>Strong emphasis, aka bold, with <strong>asterisks</strong> or <strong>underscores</strong>.<br/></p>
<p>Strikethrough uses two tildes. <u>Scratch this.</u><br/></p>
```

### Links

```
[I&#39;m an inline-style link](https://www.google.com)
[I&#39;m an inline-style link with title](https://www.google.com &quot;Google&#39;s Homepage&quot;)
``` 

will be transformed into:

```
<p><a href="https://www.google.com">I&#39;m an inline-style link</a><br/></p>
<p><a href="https://www.google.com" title="&quot;Google&#39;s Homepage&quot;">I&#39;m an inline-style link with title</a><br/></p>
```
### Images

```
![alt text](http://shuminsun.github.io/images/40.png &quot;Logo Title Text 1&quot;)
```
will be transformed into:
```
<img src="https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png" title="&quot;Logo Title Text 1&quot;" alt="alt text" />
```
### Code 

<pre>
```
var s = "JavaScript syntax highlighting";
alert(s);
```
</pre>

```
<pre class="lang-javascript">
var s = &quot;JavaScript syntax highlighting&quot;;
alert(s);
</pre>
```

### Table

```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```

will be transformed into:

```
<table><tr><th> Tables        </th><th> Are           </th><th style="text-align: center;"> Cool </th></tr><tr><td> col 3 is      </td><td> right-aligned </td><td style="text-align: center;"> $1600 </td></tr><tr><td> col 2 is      </td><td> centered      </td><td style="text-align: center;">   $12 </td></tr><tr><td> zebra stripes </td><td> are neat      </td><td style="text-align: center;">    $1 </td></tr></table><p>The outer pipes (|) are optional, and you don&#39;t need to make the raw Markdown line up prettily. You can also use inline Markdown.<br/></p>
```

    
## Feedback 

If you have any suggestion or feedback, feel free to drop me a message or follow me on [twitter @markmarknote](https://twitter.com/markmarknote)