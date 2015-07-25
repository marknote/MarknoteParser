//
//  MarkNoteParser.swift
//  MarkNoteParser
//
//  Created by bill on 25/7/15.
//  Copyright (c) 2015 MarkNote. All rights reserved.
//

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
    
    func handleLine(line:String) {
        //line = line.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
        // detect heads
        //var bHead = [Bool]()
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
        addHeadBegin(nFindHead)
        //output += line.substringFromIndex(pos).trim()
        //line = this.handleImage(line, sb);
        //line = handleKey(line.substring(nFindHead), sb);
        //handleBold(line.substringFromIndex(pos).trim())
        var remaining = line.substringFromIndex(pos).trim()
        remaining = handleTag(remaining, tag: "**", replace: "strong")
        remaining = handleTag(remaining, tag: "__", replace: "strong")
        remaining = handleTag(remaining, tag: "*", replace: "em")
        remaining = handleTag(remaining, tag: "_", replace: "em")
        remaining = handleTag(remaining, tag: "`", replace: "code")
        output += remaining
        
        addHeadEnd(nFindHead)
    }



    func addHeadBegin(nHeadLevel:Int) {
        // add head begin
        if (nHeadLevel > 0) {
            if nCurrentBulletLevel > 0  {
                for i in 0...(nCurrentBulletLevel-1) {
                    output  += "</ul>"
                }
            }
            self.nCurrentBulletLevel = 0
            output  += "<h\(nHeadLevel)>"
        }
        
    }
    
    func addHeadEnd(nHeadLevel:Int) {
        // add head end
        if nHeadLevel > 0 {
            output += "</h\(nHeadLevel)>"
        }
    }
    
    
    func handleTag(input:String,tag:String, replace:String )->String {
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
                    return handleTag(
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
