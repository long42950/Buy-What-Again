//
//  KeyCodeGen.swift
//  Buy_What_Again Simple_Shopping_List
//
//  Created by Chak Lee on 14/5/19.
//  Copyright © 2019 Chak Lee. All rights reserved.
//

import Foundation

//The KeyCode class is responsible for generating a random backup key for a backup item list stored in Firebase.
//A keycode are in the size of 12 character, including only 6 numeric, 3 upper case and 3 lower case english character.
//A keycode is an array of Char but it can only be retrieved as a String value.
//A keycode will never have two or more consecutive character inside itself.
class KeyCode: NSObject {
    
    private var length = 12
    private var availableNum = 6
    private var availableUpper = 3
    private var availableLower = 3
    private var lastChar: Character = "\u{1F1FA}\u{1F1F8}"
    
    private var keyCode: [Character] = []
    
    //Generate the key code with 12 random number
    func generateKeyCode() {
        while (length != 0) {
            keyCode.append(randomNum())
            length -= 1
        }
    }
    
    //Return the key code as String
    func toString() -> String {
        var rtnValue: String = ""
        
        for char in keyCode {
            rtnValue += "\(char)"
        }
        
        return rtnValue
    }
    
    //Randomly select a number between 48 and 122
    private func randomNum() -> Character {
        var randomN: Int = -1
        var rtnValue: Character?
        while (true) {
            randomN = Int.random(in: 48 ... 122)
            //The selected number cannot be the same as the last one
            if (lastChar == Character(UnicodeScalar(randomN)!)) {
                continue
            }
            
            switch randomN {
            //If a type of character reached the maximum limit it will another type of character
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
