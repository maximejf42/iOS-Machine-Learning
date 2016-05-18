//
//  Hash.h
//  ObjcHash
//
//  Created by Matt Eaton on 5/1/16.
//  Copyright © 2016. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hash : NSObject {
    NSMutableArray *alreadyUsed;
    int index, matchIndex;
    BOOL found;
    NSString *key, *letters, *prefixString;
}

// Function prototypes
-(void)executeHashLoop;

@end
