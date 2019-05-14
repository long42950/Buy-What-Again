//
//  KeyCodeGen.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 14/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

class KeyCode: NSObject {
    
    private var length = 12
    private var availableNum = 6
    private var availableUpper = 3
    private var availableLower = 3
    private var lastChar: Character = "\u{1F1FA}\u{1F1F8}"
    
    private var keyCode: [Character] = []
    
    func generateKeyCode() {
        while (length != 0) {
            keyCode.append(randomNum())
            length -= 1
        }
    }
    
    func toString() -> String {
        var rtnValue: String = ""
        
        for char in keyCode {
            rtnValue += "\(char)"
        }
        
        return rtnValue
    }
    
    private func randomNum() -> Character {
        var randomN: Int = -1
        var rtnValue: Character?
        while (true) {
            randomN = Int.random(in: 48 ... 122)
            if (lastChar == Character(UnicodeScalar(randomN)!)) {
                continue
            }
            
            switch randomN {
                
            case 48 ... 57:
                if (availableNum != 0) {
                    rtnValue = Character(UnicodeScalar(randomN)!)
                    availableNum -= 1
                }
            case 65 ... 90:
                if (availableUpper != 0) {
                    rtnValue = Character(UnicodeScalar(randomN)!)
                    availableUpper -= 1
                }
            case 97 ... 122:
                if (availableLower != 0) {
                    rtnValue = Character(UnicodeScalar(randomN)!)
                    availableLower -= 1
                }
                
            default:
                continue
            }
            
            if (rtnValue != nil){
                lastChar = rtnValue!
                return rtnValue!
            }
            else {
                continue
            }
            
        }
    }
    
}
