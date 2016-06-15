//
//  ObjCTryCatch.m
//  Temperatures-OSX
//
//  Created by Manuel Leitold on 15.06.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

#import "ObjCTryCatch.h"

@implementation ObjCTryCatch

+ (BOOL)executeSafe:(void(^_Nonnull)())block {
    @try {
        block();
        return true;
    } @catch (NSException *exception) {
        return false;
    }
}

@end
