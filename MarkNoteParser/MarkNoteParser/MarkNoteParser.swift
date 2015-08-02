/**
* MarknoteParser- a markdown parser
* Copyright (c) 2015, MarkNote. (MIT Licensed)
* https://github.com/marknote/MarknoteParser
*/

import UIKit

public class MarkNoteParser: NSObject {
    
    //var nOldBulletLevel = 0
    var nCurrentBulletLevel = 0
    var bInTable = false
    var output = ""
    var isInParagraph = false
    var isAfterEmptyLine = false
    var tableColsAlignment = [String]()
    let headerChar:Character = "#"
    
    public static func toHtml(input:String) -> String{
        var instance = MarkNoteParser()
        instance.output = ""
        instance.parse(input)
        return instance.output
    }
    
    func parse (input:String){
        proceedHTMLTags(input)
    }
    
    
    func proceedHTMLTags(input:String){
        var currentPos = 0
        var tagBegin = input.indexOf("<")
        if tagBegin > 0 {
            proceedNoHtml(input.substring(currentPos, end: tagBegin - 1))
            //currentPos = tagBegin
            if tagBegin < input.length - 1 {
                var left = input.substring(tagBegin, end: input.length - 1)
                var endTag = left.indexOf(">")
                if endTag > 0 {
                    // found
                    if left[endTag - 1] == "/" {
                        //auto close: <XXX />
                        self.output += left.substringToIndex(advance(left.startIndex, endTag))
                        if endTag < left.length - 1 {
                            proceedHTMLTags(left.substringFromIndex(advance(left.startIndex,endTag )))
                        }
                    } else {
                        // there is a close tag
                        currentPos = endTag
                        if endTag <= left.length - 1 {
                            left = left.substringFromIndex(advance(left.startIndex,endTag + 1 ))
                            endTag = left.indexOf(">")
                            if endTag > 0 {
                                self.output += input.substring(tagBegin, end: tagBegin + endTag + currentPos + 1) //+ left.substringToIndex(advance(left.startIndex,endTag ))
                                if endTag < left.length - 1 {
                                    left = left.substringFromIndex(advance(left.startIndex,endTag + 1 ))
                                    proceedHTMLTags(left)
                                    return
                                }
                            } else {
                                proceedNoHtml(input)
                                return
                            }
                        } else {
                            output += input
                            return
                        }
                    }
                }else {
                    // not found
                    proceedNoHtml(left)
                }
            }
        }else {
            proceedNoHtml(input)
        }
    }
    func proceedNoHtml (input:String){
        var preProceeded = input.stringByReplacingOccurrencesOfString("\r\n", withString:"\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        
        //let lines = split(preProceeded){$0 == "\n"}
        let lines = preProceeded.componentsSeparatedByString("\n")
        var isInCodeBlock:Bool = false
        var blockEndTags = [String]()
        
        //for rawline in lines {
        for var i = 0; i < lines.count; i++ {
            let line = lines[i].trim()
            
            if isInCodeBlock {
                if line.indexOf("```") == 0 {
                    isInCodeBlock = false
                    output += "</pre>\n"
                    continue
                }else {
                    output += line.replaceAll("\"", toStr:"&quot;") + "\n"
                }
            } else if bInTable && line.length > 0 {
                handleTableLine(line, isHead:false)
            } else {
                // not in block
                if  line.length == 0 {
                    // empty line
                    for var i = blockEndTags.count - 1; i >= 0; i-- {
                        output += blockEndTags[i]
                        blockEndTags.removeAtIndex(i)
                    }
                    blockEndTags.removeAll(keepCapacity: false)
                    closeParagraph()
                    closeTable()
                    
                    isAfterEmptyLine = true
                    
                    continue
                }else {
                    isAfterEmptyLine = false
                }
                
                if line.indexOf("- ") == 0 {
                    if self.nCurrentBulletLevel == 0 {
                        output += "<ul>\n"
                        blockEndTags.append("</ul>\n")
                        self.nCurrentBulletLevel = 1
                    }
                    output += "<li>"
                    let newline = line.substring("- ".length, end: line.length - 1)
                    handleLine(newline)
                    output += "</li>\n"
                    continue
                } else {
                    if self.nCurrentBulletLevel > 0 {
                        self.nCurrentBulletLevel = 0
                        output += "</ul>\n"
                    }
                }
                
                if  line.indexOf("```") == 0 {
                    isInCodeBlock = true
                    var cssClass = "no-highlight"
                    if line.length > "```".length {
                        //prettyprint javascript prettyprinted
                        let remaining = line.substringFromIndex(advance(line.startIndex, "```".length))
                        cssClass = "lang-\(remaining)"
                    }
                    output += "<pre class=\"\(cssClass)\">\n"
                    continue // ignor current line
                }

                if i + 1 <= lines.count - 1 {
                    let nextLine = lines[i + 1].trim()
                    if nextLine.contains3PlusandOnlyChars("="){
                        output += "<h1>" + line + "</h1>\n"
                        i++
                        continue
                    } else if nextLine.contains3PlusandOnlyChars("-"){
                        output += "<h2>" + line + "</h2>\n"
                        i++
                        continue
                    } else if  nextLine.indexOf("|") >= 0
                        && line.indexOf("|") >= 0
                        && nextLine.replaceAll("|", toStr: "").replaceAll("-", toStr: "").replaceAll(":", toStr: "").replaceAll(" ", toStr: "").length == 0
                        {
                            
                            beginTable(nextLine)
                            handleTableLine(line, isHead:true)
                            i++
                            continue
                        }
                }                
                
                
                handleLine(line)
                if lines[i].length >= 2
                    && lines[i].substringFromIndex(advance(lines[i].startIndex, lines[i].length - 2)) == "  " {
                        output += "<br/>"
                }
                
                //output += "</p>"
            }
        }//end for
        for var i = blockEndTags.count - 1; i >= 0; i-- {
            output += blockEndTags[i] + "\n"
            blockEndTags.removeAtIndex(i)
        }
        blockEndTags.removeAll(keepCapacity: false)
        closeParagraph()
        
    }
    
    func handleTableLine(rawline:String, isHead:Bool) {
        
        let cols = split(rawline){$0 == "|"}
        output += "<tr>"
        var i = 0
        
        for col in cols {
            let colAlign = self.tableColsAlignment[i]
            if isHead {
                output += colAlign.length > 0 ? "<th \(colAlign)>" : "<th>"
                parseInLine(col)
                output += "</th>"
            } else {
                output += colAlign.length > 0 ? "<td \(colAlign)>" : "<td>"
                parseInLine(col)
                output += "</td>"
            }
            i++
        }
        output += "</tr>"
    }
    
    func beginTable(alignmentLine: String){
        if !bInTable {
            bInTable = true
            output += "<table>"
            self.tableColsAlignment.removeAll(keepCapacity: false)
            let arr = alignmentLine.componentsSeparatedByString("|")
            for col in arr {
                if col.indexOf(":-") >= 0 && col.indexOf("-:") > 0 {
                    self.tableColsAlignment.append("style=\"text-align: center;\"")
                }else if col.indexOf("-:") > 0{
                    self.tableColsAlignment.append("style=\"text-align: right;\"")
                }else {
                    self.tableColsAlignment.append("")
                }
            }
        }
    }
    func closeTable(){
        if bInTable {
            bInTable = false
            output += "</table>"
        }
    }
    
    func closeParagraph () {
        if isInParagraph {
            isInParagraph = false
            output += "</p>\n"
        }
    }
    
    func beginParagraph(){
        if !isInParagraph {
            isInParagraph = true
            output += "<p>"
        }
    }
    
    
    
    func calculateHeadLevel(line:String)->Int{
        var nFindHead = 0
        var pos: String.Index = line.startIndex
        for var i = 0; i <= 6 && i < count(line); i++ {
            pos = advance(line.startIndex,i)
            if line[pos] == headerChar  {
                nFindHead = i + 1
            } else {
                break;
            }
        }
        return nFindHead
    }
    
    func handleLine(rawline:String) {
        
        if rawline.contains3PlusandOnlyChars("-")
        || rawline.contains3PlusandOnlyChars("*")
        || rawline.contains3PlusandOnlyChars("_"){
            closeParagraph()
            output += "<hr>\n"
            return
        }
        var line = rawline
        var endTags = [String]()
        
        var pos: String.Index = line.startIndex
        
        if line[0] == ">" {
            output += "<blockquote>"
            line = line.substringFromIndex(advance(line.startIndex,">".length))
            endTags.append("</blockquote>")
        }
        
        var nFindHead = calculateHeadLevel(line)
        if (nFindHead > 0) {
            output  += "<h\(nFindHead)>"
            endTags.append("</h\(nFindHead)>")
            pos = advance(pos, nFindHead)
        } else {
            beginParagraph()
        }
     
        //line = this.handleImage(line, sb)
        
        var remaining = line.substringFromIndex(pos).trim()
        parseInLine(remaining)
        //output += "\n"
        
        for var i = endTags.count - 1; i >= 0; i-- {
            output += endTags[i]
        }
        
        //output += "\n"
        
    }
    
    func parseInLine(line: String) {
        let len = line.length
        let start = line.startIndex
        for var i = 0; i < len ; i++ {
            let ch = line[advance(start, i)]
            
            switch ch {
            case "*":
                if (i + 1 > len - 1) {
                    output.append(ch)
                    return
                }
                if line[advance(start, i + 1)] == "*" {
                    //possible **
                    let remaining = line.substringFromIndex(advance(start, i + 2))
                    i += scanClosedChar("**",inStr: remaining,tag: "strong") + 1
                } else {
                    let remaining = line.substringFromIndex(advance(start, i + 1))
                    i += scanClosedChar("*",inStr: remaining,tag: "em")
                }
            case "_":
                if (i + 1 > len - 1) {
                    self.output.append(ch)
                    return 
                }
                if line[advance(start, i + 1)] == "_" {
                    //possible __
                    let remaining = line.substringFromIndex(advance(start, i + 2))
                    i += scanClosedChar("__",inStr: remaining,tag: "strong") + 1

                } else {
                    let remaining = line.substringFromIndex(advance(start, i + 1))
                    i += scanClosedChar("_",inStr: remaining,tag: "em")
                }
            case "~":
                if (i + 1 > len - 1) {
                    self.output.append(ch)
                    return
                }
                if line[advance(start, i + 1)] == "~" {
                    //possible ~~
                    let remaining = line.substringFromIndex(advance(start, i + 2))
                    i += scanClosedChar("~~",inStr: remaining,tag: "u") + 1
                    
                } else {
                    let remaining = line.substringFromIndex(advance(start, i + 1))
                    i += scanClosedChar("~",inStr: remaining,tag: "em")
                }
            case "`":
                let remaining = line.substringFromIndex(advance(start, i + 1))
                i += scanClosedChar("`",inStr: remaining,tag: "code")
            case "!":
                
                if i >= line.length - 1 || line[advance(start, i + 1)] != "[" {
                    output.append(ch)
                    continue
                }
                i++
                let remaining = line.substringFromIndex(advance(start, i + 1))
                let posArray = MarkNoteParser.detectPositions(["]","(",")"],inStr: remaining)
                if posArray.count == 3 {
                    let title = line.substring(i + 1, end: i + 1 + posArray[0] - 1)
                    let url = line.substring( i + 1 + posArray[1] + 1, end: i + 1 + posArray[2] - 1)
                    let posSpace = url.indexOf(" ")
                    if posSpace > 0 {
                        let urlBody = url.substring(0, end: posSpace - 1)
                        let urlTile = url.substringFromIndex(advance(url.startIndex, posSpace + 1))
                        output += "<img src=\"\(urlBody)\" title=\"" + urlTile.replaceAll("\"", toStr: "") + "\" alt=\"\(title)\" />"
                    } else {
                        output += "<img src=\"\(url)\" alt=\"\(title)\" />"
                    }
                    i +=  posArray[2] + 1
                }

            case "[":
                let remaining = line.substringFromIndex(advance(start, i + 1))
                let posArray = MarkNoteParser.detectPositions(["]","(",")"],inStr: remaining)
                if posArray.count == 3 {
                    let title = line.substring(i + 1, end: i + 1 + posArray[0] - 1)
                    let url = line.substring( i + 1 + posArray[1] + 1, end: i + 1 + posArray[2] - 1)
                    let posSpace = url.indexOf(" ")
                    if posSpace > 0 {
                        let urlBody = url.substring(0, end: posSpace - 1)
                        let urlTile = url.substringFromIndex(advance(url.startIndex, posSpace + 1))
                        output += "<a href=\"" + urlBody + "\" title=\"" + urlTile.replaceAll("\"", toStr: "") + "\">" + title + "</a>"
                    } else {
                        output += "<a href=\"" + url + "\">" + title + "</a>"
                    }
                    i +=  posArray[2] + 1
                }
            default:
                //do nothing
                output.append(ch)
            }        
        }
    }
    
    public static func detectPositions(toFind:[String],inStr:String )->[Int]{
        var posArray = [Int]()
        let count = toFind.count
        var lastPos = 0
        for var i = 0; i < count ; i++ {
            let pos = inStr.substringFromIndex(advance(inStr.startIndex, lastPos)).indexOf(toFind[i])
            lastPos += pos 
            if pos >= 0 {
                posArray.append(lastPos)
            }else {
                return posArray
            }
        }
        return posArray
    }
    
    func  scanClosedChar(ch:String, inStr:String,tag:String) -> Int {
        let pos = inStr.indexOf(ch)
        if pos > 0 {
            output += "<\(tag)>" + inStr.substringToIndex(advance(inStr.startIndex,  pos )) + "</\(tag)>"
        } else {
            output += ch
        }
        return pos + ch.length 
    }
  
   
}
