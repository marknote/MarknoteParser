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
        
        for rawline in lines {
            let line = rawline.trim()
            if line.length == 0 {
                // empty line
                continue
            }
            if !isInCodeBlock && line.indexOf("```") == 0 {
                isInCodeBlock = true
                output += "<code>"
                continue // ignor current line
            }
            
            if !isInCodeBlock {
                handleLine(line)
            } else {
                if line.indexOf("```") == 0 {
                    isInCodeBlock = false
                    output += "</code>"
                    continue
                }else {
                    output += line
                }
            }
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
        remaining = handleTagPair(remaining, tag: "**", replace: "strong")
        remaining = handleTagPair(remaining, tag: "__", replace: "strong")
        remaining = handleTagPair(remaining, tag: "*", replace: "em")
        remaining = handleTagPair(remaining, tag: "_", replace: "em")
        remaining = handleTagPair(remaining, tag: "`", replace: "code")
        output += remaining
        
        for var i = endTags.count - 1; i >= 0; i-- {
            output += endTags[i]
        }
    }
    
    func handleTagPair(input:String,tag:String, replace:String )->String {
        var linepart = input.trim()
        var nBegin = linepart.indexOf(tag)
        let tagLenth = tag.length
        
        var nEnd = 0
        if (nBegin >= 0) {            
            nEnd = linepart
                .substringFromIndex(advance(linepart.startIndex, nBegin + tagLenth))
                .indexOf(tag)
            if (nEnd > nBegin) {
                // tag found
                if nBegin > tag.length {
                    output += linepart.substring(0, end:nBegin - tagLenth)
                }
                output += "<\(replace)>"
                output += linepart.substring(nBegin + tagLenth, end: nEnd + nBegin + tagLenth - 1)
                output += "</\(replace)>"
                if nEnd < linepart.length - tag.length {
                    var remaining = linepart.substringFromIndex( advance( linepart.startIndex, nBegin + tagLenth + nEnd + tagLenth))
                    return handleTagPair(
                        remaining,
                        tag:tag,
                        replace:replace
                    )
                } else {
                    return ""
                }
            } else {
                return linepart
            }
        } else {
            return linepart
        }
        
    }
   
}
