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
will be transform into:
<h1>H1</h1><h2>H2</h2><h3>H3</h3><h4>H4</h4><h5>H5</h5><h6>H6</h6><p>Alternatively, for H1 and H2, an underline-ish style:<br/></p>
<h1>Alt-H1</h1>
<h2>Alt-H2</h2>





    
## Feedback 

If you have any suggestion or feedback, feel free to drop me a message or follow me on [twitter @markmarknote](https://twitter.com/markmarknote)