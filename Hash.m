//
//  Hash.m
//  ObjcHash

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

#import "Hash.h"

@implementation Hash

- (id)init {
    
    if ((self = [super init])) {
        // Already used array to keep record of all of our tested attempts
        alreadyUsed = [NSMutableArray array];
        // Index to keep track of the total iterations
        index = 0;
        // The match index of the potential key and the key
        matchIndex = 0;
        // Flag if the hash string has been found
        found = NO;
        // The known good key
        key = @"25377615533200";
        // The letters we were given
        letters = @"acdegilmnoprstuw";
        // The blank prefix string to hold our good characters
        prefixString = @"";
    }
    return self;
}

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
-(void)attemptPrefix:(NSString *)hash andRandomString:(NSString *)randomStr {
    
    NSRange needleRange = NSMakeRange(matchIndex, (matchIndex +1));
    NSString *p_str = [hash substringWithRange:needleRange];
    NSString *k_str = [key substringWithRange:needleRange];
    
    NSRange needleRange2 = NSMakeRange(matchIndex, (matchIndex +2));
    NSString *p_str2 = [hash substringWithRange:needleRange2];
    NSString *k_str2 = [key substringWithRange:needleRange2];
    
    NSRange needleRange3 = NSMakeRange(matchIndex, (matchIndex +3));
    NSString *p_str3 = [hash substringWithRange:needleRange3];
    NSString *k_str3 = [key substringWithRange:needleRange3];
    
    if ([p_str isEqualToString:k_str] && [p_str2 isEqualToString:k_str2] && [p_str3 isEqualToString:k_str3]) {
        char c = [randomStr characterAtIndex:matchIndex];
        prefixString = [NSString stringWithFormat:@"%@%@",prefixString, [NSString stringWithFormat:@"%c",c]];
        matchIndex++;
        if ((matchIndex * 2 + 3) < hash.length) {
            [self attemptPrefix:hash andRandomString:randomStr];
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
-(void)hashString:(NSString *)hash {
    
    // Use the long long so we do not overflow
    long long h = 7;
    // Loop through all characters in the hash string, get their index in the letters string and perform the calculation based upon position index
    for (int i = 0; i < hash.length; i++) {
        char c = [hash characterAtIndex:i];
        NSRange range = [letters rangeOfString:[NSString stringWithFormat:@"%c",c] options:NSBackwardsSearch range:NSMakeRange(0, letters.length)];
        int pos = (int)range.location;
        h = (h * 37 + pos);
    }

    NSString *h_string = [NSString stringWithFormat:@"%lld", h];
    // Check to see if the string version of the potential key matches the given key
    if ([key isEqualToString:h_string]) {
        // If there is a match flag to stop the program and display results
        NSLog(@"String found on attempt %d using string %@ to match %lld", index, hash, h);
        found = YES;
    } else {
        
        // If there is not a match send the potential key and the passed in hash string to attempt to generate a prefix
        if ((matchIndex * 2 + 3) < h_string.length) {
            [self attemptPrefix:h_string andRandomString:hash];
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
-(NSString *)getRandomString:(int)stringLength {
    
    // Random string about to be generated
    NSString *randomString = @"";
    
    // For loop to generate a string based upon the passed in size
    // The string is generated at random based off the letters string
    for (int i = 0; i < stringLength; i++) {
        int rand = arc4random_uniform((unsigned int)letters.length);
        char c = [letters characterAtIndex:rand];
        randomString = [NSString stringWithFormat:@"%@%@",randomString, [NSString stringWithFormat:@"%c",c]];
    }
    // Return the new string
    return randomString;
}

/**
 * Execution function that performs five operations
 * 1) Gathers a random string at a dynamic length
 * 2) Appends that string to the prefix string to form the semi random string.
 * 3) Checks to see if the newly semi random string is in the used array already
 * 4) Sends the the semi random string to be calculated into a numeric value in the hashString function
 * 5) Exits the loop before iteration 5000
 */
-(void)executeHashLoop {
    
    // Lets the user know that we have started looking for the string
    NSLog(@"Looking for string...");

    // While loop that performs the brute force functionality
    // This loop gets a string randomly from our set of characters
    // After that the characters are appended to the prefix and sent
    // to be checked based upon the algorithm provided
    while(found == NO && index < 5000) {
        
        int randomLength = (8 - (int)prefixString.length);
        NSString *random = [self getRandomString:randomLength];
        NSString *attempt = [NSString stringWithFormat:@"%@%@", prefixString, random];
        
        // Make sure the attempt string has not already been tried to save processing power
        if (![alreadyUsed containsObject:attempt]) {
            // Add to attempt array
            [alreadyUsed addObject:attempt];
            // Run the hash algorithm
            [self hashString:attempt];
            // Increment the index
            index++;
        }
        
        // This just lets the user know that the loop is done if for some reason the correct match is not found already
        if (index == 4999) {
            NSLog(@"Exiting program at index 4999");
            break;
        }
        
        // Utility check to display if the operating index is above a certain thousand
        if (index % 1000 == 0) {
            NSLog(@"Currently iterating at index %d", index);
        }
    }
    
}
@end
