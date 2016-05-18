//
//  Hash.swift
//  SwfitHash
//
//  Hash generation program that builds a hash string based upon failed attempts.
//  The failed attempts are checked for potential matches and saved as prefix characters to lessen the amount randomized strings that need to be generated downstream.
//  This is sort of like machine learning in a sense that everytime information is generated it is checked for potential good results and then these good results end up
//  allowing the program to find the unkwown string in the shortest amount of time
//
//  On average the loop is iterated around 1000 times to find the unknown hash
//  I have seen results come back in on the low end of 260 iterations and on the high end of 2200 iterations
//
//  Created by Matt Eaton on 5/1/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

class Hash {
    
    // Class properties
    
    // Already used array to keep record of all of our tested attempts
    var alreadyUsed = [String]()
    // Index to keep track of the total iterations
    var index:Int = 0
    // The match index of the potential key and the key
    var matchIndex:Int = 0
    // Flag if the hash string has been found
    var found:Bool = false
    // The known good key
    let key: String = "25377615533200"
    // The letters we were given
    let letters:String = "acdegilmnoprstuw"
    // The blank prefix string to hold our good characters
    var prefixString:String = ""
    
    /**
     * Utility function that attempts to define a match based upon a failed attempt.
     * Even though the potential key was not a match there could be some good information we can extract.
     * This function attempts to generate prefix characters from the potential key based upon incremental string matches from the given key.
     * This is sort of like machine learning in a sense because we are going to take the known good information and use it to help the program out downstream so it does not have to generate a random string that is 8 characters every time.  Thus cutting iterations off our total loop.
     *
     * @param hash
     *  The generated potential key
     * @param randomStr
     *  The random string generated to exrtract prefix characters from
     */
    func attemptPrefix(hash:String, randomStr:String) {
        
        // Generate three sets of substrings to try and reduce the amount of false positives in the calculation
        let p_str = hash.substringFromIndex(hash.startIndex.advancedBy(matchIndex)).substringToIndex(hash.startIndex.advancedBy((matchIndex + 1)))
        let k_str = key.substringFromIndex(key.startIndex.advancedBy(matchIndex)).substringToIndex(key.startIndex.advancedBy((matchIndex + 1)))
        
        let p_str2 = hash.substringFromIndex(hash.startIndex.advancedBy(matchIndex)).substringToIndex(hash.startIndex.advancedBy((matchIndex + 2)))
        let k_str2 = key.substringFromIndex(key.startIndex.advancedBy(matchIndex)).substringToIndex(key.startIndex.advancedBy((matchIndex + 2)))

        let p_str3 = hash.substringFromIndex(hash.startIndex.advancedBy(matchIndex)).substringToIndex(hash.startIndex.advancedBy((matchIndex + 3)))
        let k_str3 = key.substringFromIndex(key.startIndex.advancedBy(matchIndex)).substringToIndex(key.startIndex.advancedBy((matchIndex + 3)))
        
        // IF the three sets of substrings match then it is safe to extract the first character at matchIndex to add to the prefixString
        if (p_str == k_str && p_str2 == k_str2 && p_str3 == k_str3) {
            prefixString += String(randomStr[randomStr.startIndex.advancedBy(matchIndex)])
            matchIndex+=1
            // Detect if we can run this function again try and define another prefix character
            if ((matchIndex * 2 + 3) < hash.characters.count) {
                attemptPrefix(hash, randomStr: randomStr);
            }
        }
    }
    
    /**
     * Utility function that multiplies 37 * calculated number plus the character index
     * This is in attempt to generate a number key that matches the given one (25377615533200)
     * If this function matches the key it will flag to stop the program and display results
     *
     * @param hash
     *  This is the random hash that will be attempted
     *
     */
    func hashString(hash:String) {
        
        // The h int to be calculated to form the potential key
        var h:Int = 7
        // Hash array forms an array of characters based upon the input string
        let hashArray = [Character](hash.characters)
        
        // Loop through all characters in the hash array and perform the calculation
        for i in (0..<hashArray.count) {
            let ind = letters.characters.indexOf(hashArray[i])
            let pos = letters.startIndex.distanceTo(ind!)
            h = (h * 37 + Int(pos))
        }
        // Check to see if the string version of the potential key matches the given key
        if (key == String(h)) {
            // If there is a match flag to stop the program and display results
            print("String found on attempt \(index) using string \(hash) to match \(h)")
            found = true
        } else {
            // If there is not a match send the potential key and the passed in hash string to attempt to generate a prefix
            if ((matchIndex * 2 + 3) < String(h).characters.count) {
                attemptPrefix(String(h), randomStr:hash);
            }
        }
    }
    
    /**
     * Utility function that generates a random string based upon a specific set of characters
     *
     * @param stringLength
     *  The length of the desired random string
     *
     * @return string
     *  The random string generated
     */
    func getRandomString(stringLength:Int) -> String {
        
        // The character array
        let characterArray = [Character](letters.characters)
        // Random string about to be generated
        var randomString: String = ""
        
        // For loop to generate a string based upon the passed in size
        // The string is generated at random based off the letters string which is not the characterArray
        for _ in (0..<stringLength) {
            let rand = Int(arc4random_uniform(UInt32(characterArray.count)))
            randomString += String(characterArray[rand])
        }
        // Return the new string
        return randomString
    }
    
    /**
     * Execution function that performs five operations
     * 1) Gathers a random string at a dynamic length
     * 2) Appends that string to the prefix string to form the semi random string.
     * 3) Checks to see if the newly semi random string is in the used array already
     * 4) Sends the the semi random string to be calculated into a numeric value in the hashString function
     * 5) Exits the loop before iteration 5000
     */
    func executeHashLoop() {
        
        // Lets the user know that we have started looking for the string
        print("Looking for string...")
        
        // While loop that performs the brute force functionality
        // This loop gets a string randomly from our set of characters
        // After that the characters are appended to the prefix and sent
        // to be checked based upon the algorithm provided
        while (found == false && index<5000) {
            
            var randomLength:Int = 8
            randomLength-=prefixString.characters.count
            let random:String = getRandomString(randomLength)
            let attempt:String = prefixString + random
            
            // Make sure the attempt string has not already been tried to save processing power
            if !alreadyUsed.contains(attempt) {
                // Add to attempt array
                alreadyUsed.append(attempt)
                // Run the hash algorithm
                hashString(attempt)
                // Increment the index
                index+=1
            }
            
            // This just lets the user know that the loop is done if for some reason the correct match is not found already
            if (index==4999) {
                print("Exiting program at index 4999")
                return
            }
            // Utility check to display if the operating index is above a certain thousand
            if (index % 1000 == 0) {
                print("Currently iterating at index \(index)")
            }
        }
    }
}
