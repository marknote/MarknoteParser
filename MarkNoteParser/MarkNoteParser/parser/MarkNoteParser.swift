/**
* MarknoteParser- a markdown parser
* Copyright (c) 2015, MarkNote. (MIT Licensed)
* https://github.com/marknote/MarknoteParser
*/

import UIKit

public class MarkNoteParser: NSObject {
    
    var nOldBulletLevel = 0
    var nCurrentBulletLevel = 0
    var bInTable = false
    var output = ""
    let headerChar:Character = "#"
    
    public static func toHtml(input:String) -> String{
        var instance = MarkNoteParser()
        instance.parse(input)
        return instance.output
    }
    
    func parse (input:String){
        output = ""
        var preProceeded = input.stringByReplacingOccurrencesOfString("\r\n", withString:"\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let lines = split(preProceeded){$0 == "\n"}
        var isInCodeBlock:Bool = false
        var blockEndTags = [String]()
        
        //for rawline in lines {
        for var i = 0; i < lines.count; i++ {
            let line = lines[i].trim()
            
            if isInCodeBlock {
                if line.indexOf("```") == 0 {
                    isInCodeBlock = false
                    output += "</code>"
                    continue
                }else {
                    output += line
                }
            } else {
                // not in block
                if  line.length == 0 {
                    // empty line
                    for var i = blockEndTags.count - 1; i >= 0; i-- {
                        output += blockEndTags[i]
                    }
                    blockEndTags.removeAll(keepCapacity: false)
                    continue
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
                    output += "<code>"
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
                    }
                }
                handleLine(line)
            }
        }//end for
        for var i = blockEndTags.count - 1; i >= 0; i-- {
            output += blockEndTags[i]
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
        }
     
        //line = this.handleImage(line, sb)
        
        var remaining = line.substringFromIndex(pos).trim()
        parseInLine(remaining)
        
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
            case "`":
                let remaining = line.substringFromIndex(advance(start, i + 1))
               
                i += scanClosedChar("`",inStr: remaining,tag: "code")
            default:
                //do nothing
                output.append(ch)
            }
        
        }
    }
    
    func scanClosedChar(ch:String, inStr:String,tag:String) -> Int {        
        let pos = inStr.indexOf(ch)
        if pos > 0 {
            output += "<\(tag)>" + inStr.substringToIndex(advance(inStr.startIndex,  pos )) + "</\(tag)>"
            
        } else {
            output += ch
        }
        return pos + ch.length 
    }
    
  
   
}
