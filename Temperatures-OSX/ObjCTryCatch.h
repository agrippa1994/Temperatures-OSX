//
//  ObjCTryCatch.h
//  Temperatures-OSX
//
//  Created by Manuel Leitold on 15.06.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCTryCatch : NSObject

/**
 * @brief Executes the block in a safe ObjC environment
 * @param block Block which is executed inside the ObjC try-catch handler
 * @return false if the block throws an exception otherwise true
 */
+ (BOOL)executeSafe:(void(^_Nonnull)())block;

@end
